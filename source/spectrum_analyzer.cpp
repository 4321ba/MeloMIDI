#include <vector>
//includes from godot-cpp
#include <Godot.hpp>
#include <Reference.hpp>
#include <Ref.hpp>
#include <Gradient.hpp>
#include <Image.hpp>
//include from libnyquist
#include <Decoders.h>
//include from kissfft
#include <kiss_fft.h>

using namespace std;
using namespace godot;

class SpectrumAnalyzer : public Reference {
    GODOT_CLASS(SpectrumAnalyzer, Reference);
public:
    SpectrumAnalyzer() { }

    /** `_init` must exist as it is called by Godot. */
    void _init() {
        Godot::print("Spectrum analyzer GDNative C++ code initialized");
    }
    
    
    
private:
    //here we'll store the values, evened out exponentially
    //meaning every subdivision (e.g. 9) lines represent a semitone
    vector<vector<float>> magnitudes;
    
    
    float remap(const float input_min, const float input_max, const float value, const float output_min, const float output_max) {
        //inverse lerp and lerp from
        //https://www.gamedev.net/tutorials/programming/general-and-gameplay-programming/inverse-lerp-a-super-useful-yet-often-overlooked-function-r5230/
        const float ratio = (value - input_min) / (input_max - input_min);
        return (1.0f - ratio) * output_min + ratio * output_max;
    }
    
    
    vector<float> convert_magnitudes_to_exponential_frequencies(const vector<float>& linear_magnitudes, const float low_high_exponent, const int subdivision, const float tuning, const float frequency_to_count_ratio, float& max_magnitude) {
        //frequency_to_count_ratio = sample_rate / fft_size, because count * frequency_to_count_ratio = frequency
        //now we apply a conversion from linear frequencies to exponential
        //meaning every +x rows mean *y frequencies, not +z frequencies
        //a note for those who know what they are doing: this is my Frankenstein thing, and
        //I made this "algorithm" from my "horse sense"
        //I didn't do much research on it nor do I understand stuff like discrete cosine transform
        //but this code should do something remotely similar to this:
        //https://en.wikipedia.org/wiki/Mel-frequency_cepstrum
        vector<float> exponential_magnitudes;
        for (int note = 0; note < 128; note++) {
            //midi note 69 is 440hz (or tuning for custom), and every +12 midi note is *2 in frequency
            //this is the (central) frequency of the note
            const float note_frequency = tuning * pow(2, (note - 69) / 12.0f);
            for (int sub = ceil(-subdivision / 2.0f); sub < ceil(subdivision / 2.0f); sub++) {
                //this is the central frequency of the current subdivision
                const float frequency = note_frequency * pow(2, sub / 12.0f / subdivision);
                //this is the bottom frequency of the current subdivision, it is halfway between the
                //bottom neighbour frequency and this frequency (beween their center) (not linearly, geometrically/exponentially)
                const float from_frequency = frequency / pow(2, 1 / 24.0f / subdivision);
                //same but the upper limit
                const float to_frequency = frequency * pow(2, 1 / 24.0f / subdivision);
                //these correspond to the indexes of the FFT output (count of floats)
                int begin_count = ceil(from_frequency / frequency_to_count_ratio);
                int end_count = ceil(to_frequency / frequency_to_count_ratio);
                
                float sum = 0.0f;
                if (begin_count == end_count) {
                    //for low notes we lerp between the 2 closest values
                    begin_count--;
                    const float begin_frequency = begin_count * frequency_to_count_ratio;
                    const float end_frequency = end_count * frequency_to_count_ratio;
                    sum = remap(begin_frequency, end_frequency, frequency, linear_magnitudes[begin_count], linear_magnitudes[end_count]);
                } else {
                    //for high notes we add all the in-range values together
                    for (int i = begin_count; i < end_count; i++) {
                        sum += linear_magnitudes[i];
                    }
                }
                //compensation, because we can only add whole numbers so
                //we need to smooth the border between where 1 and where 2 or more are added
                //and also magnitudes are probably 2* as loud 1 octave lower
                //because there are /2 less samples/frequencies analyzed
                //but it is configurable, because people might need upper harmonics less
                //the /440 is chosen (frequency of A4), because it's almost in the middle (note 69 out of 0-127)
                sum *= pow(frequency / 440.0f, low_high_exponent) / (end_count - begin_count);
                if (sum > max_magnitude) {
                    max_magnitude = sum;
                }
                exponential_magnitudes.push_back(sum);
            }
        }
        return exponential_magnitudes;
    }
    
    
    vector<vector<float>> analyze_subspectrum(vector<float> samples, const int sample_rate, const int fft_size, const float low_high_exponent, const float overamplification_multiplier, const int hop_size, const int subdivision, const float tuning) {
        //for a short overall description of what's happening (at least partially): https://stackoverflow.com/a/4678313
        cout << "Calculating subspectrum with parameters:" << endl;
        
        //adding silence to the beginning and to the end
        vector<float> silence;
        for (int i = 0; i < fft_size / 2; i++) {
            silence.push_back(0.0f);
        }
        samples.insert(samples.begin(), silence.begin(), silence.end());
        samples.insert(samples.end(), silence.begin(), silence.end());
        
        //we don't need all the frequencies, we only need them below 14000 Hz, because the others are above the highest midi note
        const int frequency_limit_count = 14000 * fft_size / sample_rate;
        const int sample_size = samples.size();
        cout << "FFT size is " << fft_size << endl;
        cout << "Hop size is " << hop_size << endl;
        cout << "Sample size is " << sample_size << endl;
        cout << "Frequency limit count is " << frequency_limit_count << endl;
        
        //we go through the whole wave file, and we calculate an fft with the size of fft_size, after jumping by hop_size
        float max_magnitude = 0.0f;
        vector<vector<float>> return_magnitudes;
        kiss_fft_cfg cfg = kiss_fft_alloc(fft_size, 0, 0, 0);
        kiss_fft_cpx cx_in[fft_size];
        kiss_fft_cpx cx_out[fft_size];
        for (int i = 0; i < fft_size; i++) {
            cx_in[i].i = 0.0f;
        }
        for (int current_position = 0; current_position < sample_size - fft_size; current_position += hop_size) {
            
            for (int i = 0; i < fft_size; i++) {
                //Hann window function, source: https://github.com/Kryszak/AudioSpectrum/blob/master/Mp3Player.cpp#L114
                cx_in[i].r = samples[current_position + i] * 0.5f * (1 - cos(2 * Math_PI * i / (fft_size - 1)));
            }
            kiss_fft(cfg, cx_in, cx_out);
            vector<float> linear_magnitudes;
            for (int i = 0; i < frequency_limit_count; i++) {
                linear_magnitudes.push_back(sqrt(cx_out[i].r * cx_out[i].r + cx_out[i].i * cx_out[i].i));
            }
            vector<float> exponential_magnitudes = convert_magnitudes_to_exponential_frequencies(linear_magnitudes, low_high_exponent, subdivision, tuning, float(sample_rate) / fft_size, max_magnitude);
            return_magnitudes.push_back(exponential_magnitudes);
        }
        //because of unknown reasons using kiss_fft_free throws an error
        //but this should be here according to everything, mainly https://github.com/mborgerding/kissfft#usage
        //so the absence of this probably causes some memory leak or something
        //the strange thing is when I used this outside of GDNative, it worked just fine
        //kiss_fft_free(cfg)
        //they want me to use this, which I don't know if it's good, but it works so far
        ::free(cfg);
        
        //we don't cap magnitudes at 1, they will be capped after the merge
        max_magnitude /= overamplification_multiplier;
        const int height = return_magnitudes[0].size();
        for (auto & tick_magnitudes: return_magnitudes) {
            for (int i = 0; i < height; i++) {
                tick_magnitudes[i] /= max_magnitude;
            }
        }
        cout << "Size of the subdata is " << return_magnitudes.size() << " by " << height << endl;
        return return_magnitudes;
    }
    
    
public:
    Array analyze_spectrum(PoolByteArray bytes, const bool use_2_ffts, const int fft_size_low, const float low_high_exponent_low, const float overamplification_multiplier_low, const int fft_size_high, const float low_high_exponent_high, const float overamplification_multiplier_high, const int hop_size, const int subdivision, const float tuning) {
        
        //converting godot::PoolByteArray to vector<uint8_t>
        //I figured I'll be better off reading the file with Godot, because:
        //I don't need to worry about converting godot::String to string
        //utf8 and other stuff isn't messed up in the filename
        //I can open the file the exact same way as GDScriptAudioImport.gd opens it
        //and I might as well do it in GDScript
        //this conversion is much easier than converting the path
        //I'm also concerned because on Windows Godot still C:/returns/paths/this/way
        //which libnyquist most probably won't be able to handle without me doing conversions
        vector<uint8_t> encoded_audio;
        for (int i = 0; i < bytes.size(); i++) {
            encoded_audio.push_back(bytes[i]);
        }
        
        //use libnyquist to get the raw audio data
        shared_ptr<nqr::AudioData> file_data = make_shared<nqr::AudioData>();
        nqr::NyquistIO loader;
        loader.Load(file_data.get(), encoded_audio);
        
        const int sample_rate = file_data->sampleRate;
        const int original_sample_size = file_data->samples.size();
        const int channel_count = file_data->channelCount;
        const int sample_size = original_sample_size / channel_count;
        //using cout because I couldn't find an easy way to print ints with Godot::print
        cout << "Sample rate is " << sample_rate << endl;
        cout << "Original sample size is " << original_sample_size << endl;
        cout << "Channel count is " << channel_count << endl;
        
        vector<float> samples;
        //averaging all channels so samples become mono
        for (int i = 0; i < sample_size; i++) {
            samples.push_back(accumulate(
                file_data->samples.begin() + channel_count * i,
                file_data->samples.begin() + channel_count * (i + 1),
                0.0f) / channel_count);
        }
        
        //now we call analyze_subspectrum, once or twice, and then normalize the magnitudes
        vector<vector<float>> magnitudes_low = analyze_subspectrum(samples, sample_rate, fft_size_low, low_high_exponent_low, overamplification_multiplier_low, hop_size, subdivision, tuning);
        if (use_2_ffts) {
            vector<vector<float>> magnitudes_high = analyze_subspectrum(samples, sample_rate, fft_size_high, low_high_exponent_high, overamplification_multiplier_high, hop_size, subdivision, tuning);
            
            if (magnitudes_low.size() != magnitudes_high.size() or magnitudes_low[0].size() != magnitudes_high[0].size()) {
                cout << "Warning! The resolutions of the low and high magnitudes aren't the same!" << endl;
            }
            const int width = min(magnitudes_low.size(), magnitudes_high.size());
            const int height = min(magnitudes_low[0].size(), magnitudes_high[0].size());
            
            magnitudes.clear();
            for (int x = 0; x < width; x++) {
                vector<float> merged_magnitudes;
                for (int y = 0; y < height; y++) {
                    const float normalized = y / (height - 1.0f);
                    //we're using an easing called easeInOutExpo to interpolate between the low and high ffts
                    //code source: https://easings.net/en#easeInOutExpo
                    const float weight = normalized < 0.5f ? pow(2, 20 * normalized - 10) / 2 : (2 - pow(2, -20 * normalized + 10)) / 2;
                    const float magnitude = (1.0f - weight) * magnitudes_low[x][y] + weight * magnitudes_high[x][y];
                    merged_magnitudes.push_back(min(magnitude, 1.0f));
                }
                magnitudes.push_back(merged_magnitudes);
            }
        } else {
            //we sadly need to loop through once again even if we only do one fft, I'm not that concerned with performance
            //knowing that it's much better than gdscript anyway, but I hope that these aren't slowing things down terribly
            //and by that I mean that hopefully this takes at most 0.1 s
            //we need to loop through again to clamp the magnitudes at 1, because we can't do it in analyze_subspectrum,
            //because we need the overamplified values when there are 2 ffts
            magnitudes = magnitudes_low;
            const int height = magnitudes[0].size();
            for (auto & tick_magnitudes: magnitudes) {
                for (int i = 0; i < height; i++) {
                    if (tick_magnitudes[i] > 1.0f) {
                        tick_magnitudes[i] = 1.0f;
                    }
                }
            }
        }
        
        cout << "Size of the data is " << magnitudes.size() << " by " << magnitudes[0].size() << endl;
        Array return_array;
        return_array.append(sample_rate);
        return_array.append(magnitudes.size());
        return_array.append(magnitudes[0].size());
        return return_array;
    }
    
    
    Array generate_images(Ref<Gradient> color_scheme) {
        Array images;
        //we need to split the image into multiple parts, because Godot's Image width (and height) is max 16384 (=Image::MAX_WIDTH)
        const int max_width = Image::MAX_WIDTH;
        const int number_of_images = magnitudes.size() / max_width;
        for (int image_count = 0; image_count <= number_of_images; image_count++) {
            const int width = image_count == number_of_images ? magnitudes.size() - max_width * image_count : max_width;
            vector<vector<float>> current_magnitudes(magnitudes.begin() + max_width * image_count,
                                                     magnitudes.begin() + max_width * image_count + width);
            const int height = current_magnitudes[0].size();
            cout << "Creating image with width " << width << " and height " << height << endl;
            PoolByteArray image_data;
            for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++) {
                    Color color = color_scheme->interpolate(current_magnitudes[x][y]);
                    image_data.append(color.get_r8());
                    image_data.append(color.get_g8());
                    image_data.append(color.get_b8());
                    image_data.append(color.get_a8());
                }
            }
            //there's also Image* but they say this is better and I actually got it working
            Ref<Image> image = Image::_new();
            image->create_from_data(width, height, false, Image::FORMAT_RGBA8, image_data);
            //we want low pitch to be down and high pitch to be up
            image->flip_y();
            images.append(image);
        }
        cout << "Returning " << images.size() << " images" << endl;
        return images;
    }
    
    
    PoolIntArray guess_notes(const float note_on_threshold, const float note_off_threshold, const float octave_removal_multiplier, const int minimum_length, const float volume_multiplier, const float percussion_removal) {
        
        cout << "Guessing notes..." << endl;
        const int subdivision = magnitudes[0].size() / 128;
        vector<vector<float>> note_strengths;
        for (auto & current_magnitudes: magnitudes) {
            vector<float> these_strengths;
            for (int note = 0; note < 128; note++) {
                float magnitude = 0;
                for (int i = 0; i < subdivision; i++) {
                    //we want to calculate a window-like thing, as we want the "inner" subdivisions to matter more
                    //then the "outer" ones, this is just an absolute value thing so the window will look
                    //something like this:  /\  with a peak of 3 and the sides being 1
                    magnitude += current_magnitudes[note * subdivision + i] * (3.0f - abs(i * 4.0f / (subdivision - 1) - 2.0f));
                }
                // we divide by 2 so that the maximum value becomes 1, because it ranges [0;2]
                magnitude /= 2.0f;
                if (note > 0) {
                    for (int i = 0; i < subdivision; i++) {
                        //same thing, but now it looks like this:  /\  with a peak of 0 and the sides being -1
                        //the purpose of this is to kinda exclude if there's a real note here, otherwise the goal of this whole thing is
                        //to exclude drums and other "noise" that spreads across multiple notes, so if we subtract the magnitudes from
                        //one note above and from one note below, from the current one, we get a rough idea if there's actually a note here
                        magnitude += current_magnitudes[(note - 1) * subdivision + i] * (-abs(i * 2.0f / (subdivision - 1) - 1.0f)) * percussion_removal;
                    }
                }
                if (note < 127) {
                    for (int i = 0; i < subdivision; i++) {
                        //same thing but for one note higher
                        //notice that lower magnitudes and higher magnitudes < 0 so we add them, but they only compensate negatively
                        magnitude += current_magnitudes[(note + 1) * subdivision + i] * (-abs(i * 2.0f / (subdivision - 1) - 1.0f)) * percussion_removal;
                    }
                }
                //we're clamping it at 0, meaning it can't be negative even when the surrounding notes are louder then the current one
                these_strengths.push_back(max(magnitude / subdivision, 0.0f));
            }
            note_strengths.push_back(these_strengths);
        }
        
        //now we run a second round which actually decides where note ons and offs should be
        //and optionally subtracts a fraction of the one octave lower magnitude
        const int width = note_strengths.size();
        //the format of notes: 4 ints represent a note, I just can't return it better
        //in the following order: begin_tick, end_tick, note, velocity, next_begin_tick, etc...
        PoolIntArray notes;
        for (int note = 0; note < 128; note++) {
            bool is_note_playing = false;
            int note_begin_tick = -1;
            float peak_magnitude = 0.0f;
            for (int tick = 0; tick < width; tick++) {
                float magnitude = note_strengths[tick][note];
                if (note >= 12) {
                    magnitude -= note_strengths[tick][note - 12] * octave_removal_multiplier;
                }
                if (not is_note_playing and magnitude >= note_on_threshold) {
                    is_note_playing = true;
                    note_begin_tick = tick;
                }
                if (is_note_playing and magnitude > peak_magnitude) {
                    peak_magnitude = magnitude;
                }
                if (is_note_playing and magnitude <= note_off_threshold) {
                    is_note_playing = false;
                    //we only add the note if it exceeds the minimum length given
                    //because we don't want to clutter the image with many short notes
                    if (tick - note_begin_tick >= minimum_length) {
                        notes.append(note_begin_tick);
                        notes.append(tick);
                        notes.append(note);
                        notes.append(min(int(peak_magnitude * 128 * volume_multiplier + 0.5f), 127));
                    }
                    note_begin_tick = -1;
                    peak_magnitude = 0.0f;
                }
            }
            //if we run out of width but there's still a note on
            if (is_note_playing and width - note_begin_tick >= minimum_length) {
                notes.append(note_begin_tick);
                notes.append(width);
                notes.append(note);
                notes.append(min(int(peak_magnitude * 128 * volume_multiplier + 0.5), 127));
            }
        }
        cout << notes.size() / 4 << " notes guessed" << endl;
        return notes;
    }
    
    
    
    static void _register_methods() {
        register_method("analyze_spectrum", &SpectrumAnalyzer::analyze_spectrum);
        register_method("generate_images", &SpectrumAnalyzer::generate_images);
        register_method("guess_notes", &SpectrumAnalyzer::guess_notes);
    }
};

/** GDNative Initialize **/
extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *o) {
    godot::Godot::gdnative_init(o);
}
/** GDNative Terminate **/
extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *o) {
    godot::Godot::gdnative_terminate(o);
}
/** NativeScript Initialize **/
extern "C" void GDN_EXPORT godot_nativescript_init(void *handle) {
    godot::Godot::nativescript_init(handle);

    godot::register_class<SpectrumAnalyzer>();
}
