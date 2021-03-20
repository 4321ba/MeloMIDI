#include <vector>
//includes from godot-cpp
#include <Godot.hpp>
#include <Reference.hpp>
#include <String.hpp>
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



    PoolRealArray analyze_spectrum(String filename_godot, int fft_size, int hop_size) {
        
        //use libnyquist to get the raw audio data
        std::shared_ptr<nqr::AudioData> file_data = std::make_shared<nqr::AudioData>();
        nqr::NyquistIO loader;
        Godot::print("Loading audio file " + filename_godot);
        //conversion from godot::String to std::string is from https://godotengine.org/qa/18552/gdnative-convert-godot-string-to-const-char
        std::wstring filename_wstring = filename_godot.unicode_str();
        std::string filename_string( filename_wstring.begin(), filename_wstring.end() );
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
        for (int i = 0; i < fft_size; i++) {
            samples.push_back(0.0f);
        }
        //averaging all channels so samples become mono
        for (int i = 0; i < sample_size; i++) {
            samples.push_back(std::accumulate(file_data->samples.begin() + (i * channel_count), file_data->samples.begin() + ((i+1) * channel_count), 0.0f) / channel_count);
        }
        sample_size += fft_size;
        std::cout << "Sample size is " << sample_size << std::endl;
        std::cout << "Mono sample-vector size is " << samples.size() << std::endl;
        
        //we don't need all the frequencies, we only need them below 14000 Hz, because the others are above the highest midi note
        int frequency_limit_count = 14000 * fft_size / sample_rate;
        std::cout << "FFT size is " << fft_size << std::endl;
        std::cout << "Hop size is " << hop_size << std::endl;
        std::cout << "Frequency limit count is " << frequency_limit_count << std::endl;
        
        //we go through the whole wave file, and we calculate an fft with the size of fft_size, after jumping by hop_size
        PoolRealArray magnitudes;
        kiss_fft_cfg cfg = kiss_fft_alloc(fft_size, 0, 0, 0);
        for (int current_position = 0; current_position < sample_size - fft_size; current_position += hop_size) {
            kiss_fft_cpx cx_in[fft_size];
            kiss_fft_cpx cx_out[fft_size];
            for (int i = 0; i < fft_size; i++) {
                cx_in[i].i = 0;
                //Hann window function, source: https://github.com/Kryszak/AudioSpectrum/blob/master/Mp3Player.cpp#L114
                cx_in[i].r = samples[current_position + i] * 0.5f * (1 - cos(2 * M_PI * i / (fft_size - 1)));
            }
            kiss_fft(cfg, cx_in, cx_out);
            for (int i = 0; i < frequency_limit_count; i++) {
                magnitudes.append(sqrt(cx_out[i].r * cx_out[i].r + cx_out[i].i * cx_out[i].i));
            }
        }
        //because of unknown reasons using kiss_fft_free throws an error
        //but this should be here according to everything, mainly https://github.com/mborgerding/kissfft#usage
        //so the absence of this probably causes some memory leak or something
        //the strange thing is when I used this outside of GDNative, it worked just fine
        //kiss_fft_free(cfg)
        //they want me to use this, which I don't know if it's good
        ::free(cfg);
        
        std::cout << "Size of the returned raw data is " << magnitudes.size() << std::endl;
        //I have no idea how I could return these so I'm just appending them to the end of the data
        magnitudes.append(sample_rate);
        magnitudes.append(frequency_limit_count);
        return magnitudes;
    }



    static void _register_methods() {
        register_method("analyze_spectrum", &SpectrumAnalyzer::analyze_spectrum);
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
