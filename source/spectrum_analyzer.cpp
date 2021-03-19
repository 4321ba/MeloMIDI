#include <Godot.hpp>
#include <Reference.hpp>
#include <String.hpp>

using namespace godot;

class SpectrumAnalyzer : public Reference {
    GODOT_CLASS(SpectrumAnalyzer, Reference);
public:
    SpectrumAnalyzer() { }

    /** `_init` must exist as it is called by Godot. */
    void _init() {
        Godot::print("Spectrum analyzer GDNative C++ code initialized");
    }



    PoolRealArray analyze_spectrum(String filename) {
        PoolRealArray erri = PoolRealArray();
        erri.append(12.4);
        Godot::print(filename);
        return erri;
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
