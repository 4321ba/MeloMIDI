#include <vector>
//includes from godot-cpp
#include <Godot.hpp>
#include <Reference.hpp>
#include <String.hpp>
#include <Image.hpp>
//include from libnyquist
#include <Decoders.h>
//include from kissfft
#include <kiss_fft.h>

using namespace godot;

class SpectrumAnalyzer : public Reference {
    GODOT_CLASS(SpectrumAnalyzer, Reference);
public:
    SpectrumAnalyzer() { }

    /** `_init` must exist as it is called by Godot. */
    void _init() {
        Godot::print("Spectrum analyzer GDNative C++ code initialized");
    }
    
    
    
    //here we'll store the values, evened out exponentially
    //meaning every subdivision (e.g. 9) lines represent a semitone
    std::vector<std::vector<float>> magnitudes;
    
    
    Array analyze_spectrum(String filename_godot, int fft_size, int hop_size, int subdivision, float tuning, float low_high_exponent, float overamplification_multiplier) {
        
        Godot::print("Loading audio file " + filename_godot);
        //conversion from godot::String to std::string is from https://godotengine.org/qa/18552/gdnative-convert-godot-string-to-const-char
        std::wstring filename_wstring = filename_godot.unicode_str();
        std::string filename_string(filename_wstring.begin(), filename_wstring.end());
        //use libnyquist to get the raw audio data
        std::shared_ptr<nqr::AudioData> file_data = std::make_shared<nqr::AudioData>();
        nqr::NyquistIO loader;
        loader.Load(file_data.get(), filename_string);
        
        int sample_rate = file_data->sampleRate;
        int original_sample_size = file_data->samples.size();
        int channel_count = file_data->channelCount;
        int sample_size = original_sample_size / channel_count;
        //using std::cout because I couldn't find an easy way to print ints with Godot::print
        std::cout << "Sample rate is " << sample_rate << std::endl;
        std::cout << "Original sample size is " << original_sample_size << std::endl;
        std::cout << "Channel count is " << channel_count << std::endl;
        
        std::vector<float> samples;
        //adding silence to the beginning
        for (int i = 0; i < fft_size / 2; i++) { samples.push_back(0.0f); }
        //averaging all channels so samples become mono
        for (int i = 0; i < sample_size; i++) {
            samples.push_back(std::accumulate(
                file_data->samples.begin() + channel_count * i,
                file_data->samples.begin() + channel_count * (i + 1),
                0.0f) / channel_count);
        }
        //adding silence to the end
        for (int i = 0; i < fft_size / 2; i++) { samples.push_back(0.0f); }
        sample_size += fft_size;
        std::cout << "Sample size is " << sample_size << std::endl;
        std::cout << "Mono sample-vector size is " << samples.size() << std::endl;
        
        //we don't need all the frequencies, we only need them below 14000 Hz, because the others are above the highest midi note
        int frequency_limit_count = 14000 * fft_size / sample_rate;
        std::cout << "FFT size is " << fft_size << std::endl;
        std::cout << "Hop size is " << hop_size << std::endl;
        std::cout << "Frequency limit count is " << frequency_limit_count << std::endl;
        
        //we go through the whole wave file, and we calculate an fft with the size of fft_size, after jumping by hop_size
        magnitudes.clear();
        float max_magnitude = 0;
        kiss_fft_cfg cfg = kiss_fft_alloc(fft_size, 0, 0, 0);
        kiss_fft_cpx cx_in[fft_size];
        kiss_fft_cpx cx_out[fft_size];
        for (int i = 0; i < fft_size; i++) { cx_in[i].i = 0; }
        for (int current_position = 0; current_position < sample_size - fft_size; current_position += hop_size) {
            
            for (int i = 0; i < fft_size; i++) {
                //Hann window function, source: https://github.com/Kryszak/AudioSpectrum/blob/master/Mp3Player.cpp#L114
                cx_in[i].r = samples[current_position + i] * 0.5f * (1 - cos(2 * M_PI * i / (fft_size - 1)));
            }
            kiss_fft(cfg, cx_in, cx_out);
            std::vector<float> linear_magnitudes;
            for (int i = 0; i < frequency_limit_count; i++) {
                linear_magnitudes.push_back(sqrt(cx_out[i].r * cx_out[i].r + cx_out[i].i * cx_out[i].i));
            }
            
            //now we apply a coversion from linear frequencies to exponential
            //meaning every +x rows mean *y frequencies, not +z frequencies
            //a note for those who know what they are doing: this is my Frankenstein thing, and
            //I made this "algorithm" from my "horse sense"
            //I didn't do much research on it nor do I understand stuff like discrete cosine transform
            //but this code should do something remotely similar to this:
            //https://en.wikipedia.org/wiki/Mel-frequency_cepstrum
            std::vector<float> exponential_magnitudes;
            for (int note = 0; note < 128; note++) {
                //midi note 69 is 440hz (or tuning for custom), and every +12 midi note is *2 in frequency
                float note_frequency = tuning * pow(2, (note - 69) / 12.0);
                for (int sub = ceil(-subdivision / 2.0); sub < ceil(subdivision / 2.0); sub++) {
                    float frequency = note_frequency * pow(2, sub / 12.0 / subdivision);
                    float from_frequency = frequency / pow(2, 1 / 24.0 / subdivision);
                    float to_frequency = frequency * pow(2, 1 / 24.0 / subdivision);
                    int begin_count = ceil(from_frequency * fft_size / sample_rate);
                    int end_count = ceil(to_frequency * fft_size / sample_rate);
                    
                    float sum = 0;
                    if (begin_count == end_count) {
                        //for low notes we lerp between the 2 closest values
                        begin_count--;
                        float begin_frequency = begin_count * sample_rate / float(fft_size);
                        float end_frequency = end_count * sample_rate / float(fft_size);
                        //inverse lerp and lerp from
                        //https://www.gamedev.net/tutorials/programming/general-and-gameplay-programming/inverse-lerp-a-super-useful-yet-often-overlooked-function-r5230/
                        float ratio = (frequency - begin_frequency) / (end_frequency - begin_frequency);
                        sum = (1.0 - ratio) * linear_magnitudes[begin_count] + ratio * linear_magnitudes[end_count];
                    } else {
                        //for high notes we add all the in-range values together
                        for (int i = begin_count; i < end_count; i++) { sum += linear_magnitudes[i]; }
                    }
                    //compensation, because we can only add whole numbers so
                    //we need to smooth the border between where 1 and where 2 or more are added
                    //and also magnitudes are probably 2* as loud 1 octave lower
                    //because there are /2 less samples/frequencies analyzed
                    sum *= pow(frequency / 110.0, low_high_exponent) / (end_count - begin_count);
                    if (sum > max_magnitude) { max_magnitude = sum; }
                    exponential_magnitudes.push_back(sum);
                }
            }
            magnitudes.push_back(exponential_magnitudes);
        }
        //because of unknown reasons using kiss_fft_free throws an error
        //but this should be here according to everything, mainly https://github.com/mborgerding/kissfft#usage
        //so the absence of this probably causes some memory leak or something
        //the strange thing is when I used this outside of GDNative, it worked just fine
        //kiss_fft_free(cfg)
        //they want me to use this, which I don't know if it's good, but it works so far
        ::free(cfg);
        
        max_magnitude /= overamplification_multiplier;
        int width = magnitudes[0].size();
        for (auto & tick_magnitudes: magnitudes) {
            for (int i = 0; i < width; i++) {
                tick_magnitudes[i] /= max_magnitude;
                if (tick_magnitudes[i] > 1) { tick_magnitudes[i] = 1; }
            }
        }
        std::cout << "Size of the data is " << magnitudes.size() << " by " << width << std::endl;
        
        Array return_array;
        return_array.append(sample_rate);
        return_array.append(magnitudes.size());
        return_array.append(magnitudes[0].size());
        return return_array;
    }
    
    
    Array generate_images() {
        Array images;
        int number_of_images = magnitudes.size() / 16384;
        for (int image_count = 0; image_count <= number_of_images; image_count++) {
            int width = image_count == number_of_images ? magnitudes.size() - 16384 * image_count : 16384;
            std::vector<std::vector<float>> current_magnitudes(magnitudes.begin() + 16384 * image_count,
                                                               magnitudes.begin() + 16384 * image_count + width);
            int height = current_magnitudes[0].size();
            std::cout << "Creating image with width " << width << " and height " << height << std::endl;
            PoolByteArray image_data;
            Color color;
            for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++) {
                    color = color.from_hsv(current_magnitudes[x][y], 1, 1);
                    image_data.append(color.get_r8());
                    image_data.append(color.get_g8());
                    image_data.append(color.get_b8());
                    image_data.append(color.get_a8());
                }
            }
            //I'm not 100% sure this is good, there's Ref<Image> or something like that but idk
            Image* image = Image::_new();
            image->create_from_data(width, height, false, image->FORMAT_RGBA8, image_data);
            //we want low pitch to be down and high pitch to be up
            image->flip_y();
            images.append(image);
        }
        return images;
    }
    
    
    PoolIntArray guess_notes(float note_on_threshold, float note_off_threshold, float octave_removal_multiplier, int minimum_length, float volume_multiplier, int note_recognition_negative_delay) {
        
        int subdivision = magnitudes[0].size() / 128;
        std::vector<std::vector<float>> note_strengths;
        for (auto & current_magnitudes: magnitudes) {
            std::vector<float> these_strengths;
            for (int note = 0; note < 128; note++) {
                float magnitude = 0;
                for (int i = 0; i < subdivision; i++) {
                    //we want to calculate a window-like thing, as we want the "inner" subdivisions to matter more
                    //then the "outer" ones, this is just an absolute value thing so the window will look
                    //something like this:  /\  with a peak of 2 and the sides being 1
                    magnitude += current_magnitudes[note * subdivision + i] * (2 - abs(i * 2.0 / (subdivision - 1) - 1));
                }
                // we divide by 1.5 so that the maximum value becomes 1, because it ranges [0;1.5]
                magnitude /= 1.5;
                if (note > 0) {
                    for (int i = 0; i < subdivision; i++) {
                        //same thing, but now it looks like this:  /\  with a peak of 0 and the sides being -1
                        //the purpose of this is to kinda exclude if there's a real note here, otherwise the goal of this whole thing is
                        //to exclude drums and other "noise" that spreads across multiple notes, so if we subtract the magnitudes from
                        //one note above and from one note below, from the current one, we get a rough idea if there's actually a note here
                        magnitude += current_magnitudes[(note - 1) * subdivision + i] * (-abs(i * 2.0 / (subdivision - 1) - 1));
                    }
                }
                if (note < 127) {
                    for (int i = 0; i < subdivision; i++) {
                        //same thing but for one note higher
                        //notice that lower magnitudes and higher magnitudes < 0 so we add them, but they only compensate negatively
                        magnitude += current_magnitudes[(note + 1) * subdivision + i] * (-abs(i * 2.0 / (subdivision - 1) - 1));
                    }
                }
                these_strengths.push_back(magnitude > 0 ? magnitude / subdivision : 0);
            }
            note_strengths.push_back(these_strengths);
        }
        
        //now we run a second round which actually decides where note ons and offs should be
        //and optionally subtracts a fraction of the one octave lower magnitude
        int width = note_strengths.size();
        //the format of notes: 4 ints represent a note, I just can't return it better
        //in the following order: begin_tick, end_tick, note, velocity, next begin_tick, etc...
        PoolIntArray notes;
        for (int note = 0; note < 128; note++) {
            bool is_note_playing = false;
            int note_begin_tick = -1;
            float peak_magnitude = 0;
            for (int tick = 0; tick < width; tick++) {
                float magnitude = note_strengths[tick][note];
                if (note >= 12) { magnitude -= note_strengths[tick][note - 12] * octave_removal_multiplier; }
                if (not is_note_playing and magnitude >= note_on_threshold) {
                    is_note_playing = true;
                    //if there's a note then it probably started a bit before, it just didn't reach the note_on_threshold
                    //so we try to compensate that here
                    note_begin_tick = tick - note_recognition_negative_delay;
                    if (note_begin_tick < 0) { note_begin_tick = 0; }
                }
                if (is_note_playing and magnitude > peak_magnitude) { peak_magnitude = magnitude; }
                if (is_note_playing and magnitude <= note_off_threshold) {
                    is_note_playing = false;
                    //we only add the note if it exceeds the minimum length given
                    //because we don't want to clutter the image with many short notes
                    if (tick - note_begin_tick >= minimum_length) {
                        notes.append(note_begin_tick);
                        notes.append(tick);
                        notes.append(note);
                        notes.append(peak_magnitude * 128 * volume_multiplier);
                    }
                    note_begin_tick = -1;
                    peak_magnitude = 0;
                }
            }
            //if we run out of width but there's still a note on
            if (is_note_playing and width - note_begin_tick >= minimum_length) {
                notes.append(note_begin_tick);
                notes.append(width);
                notes.append(note);
                notes.append(peak_magnitude * 128 * volume_multiplier);
            }
        }
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
