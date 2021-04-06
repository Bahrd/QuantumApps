/// # A basic triple polarizer experiment emulation
/// Usage example [Windows Terminal or the other .NET Core 3.1 compatible shell]: 
/// The command sequence:       'dotnet build --no-restore --nologo; dotnet run --no-build --all-photons 4096 --second-polariser true'
/// should approximately yield: '481 of 4096... That's about 12% of lucky photons!'
namespace TPR // A scratchpad area...
{
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Random;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;

    // A type of duck tape typing...
    newtype TripleDouble = (M: Double, Double, J: Double);                      // A tribute to MJ!
    newtype ThreePeat = (AllPhotons: Int, θ: Double, SecondPolariser: Bool);    // ... yet another!

    // A hand-made function alias/shorthand/binder...
    operation DRD(): Double
    {
        let _2π = 2.*PI();
        return DrawRandomDouble(-_2π, _2π);
    }
    operation θxθyθz(): TripleDouble
    {
        return TripleDouble(DRD(), DRD(), DRD());
    }
}
namespace TPR // Area 51...
{
    // The three polarisers experiment implementation
    operation TriplePolariser(t4t: ThreePeat) : Unit
    {   
        // We ignore here the angle between polarizers parameter θ. A reader is however encouraged 
        // to make a use of it inorder to verify how many photons will survive when θ == 22.5°.
        let (AllPhotons, _, SecondPolariser) = t4t!; // Or: 'let (AllPhotons, SecondPolariser) = (t4t::AllPhotons, t4t::SecondPolariser);'
        use ϕ = Qubit()
        {    
            mutable (MacPhotons, PhotonPL) = (0b0, Zero);
            for i in 1..AllPhotons
            {
                // Making a photon polarisation a (qu)bit random...
                // ... with a little help of two ¿bad taste? one-liners!
                let (θx, θy, θz) = (θxθyθz())!;
                let (_, _, _) = (Rx(θx, ϕ), Ry(θy, ϕ), Rz(θz, ϕ));  // Where e.g. 'Rx(θ, ϕ)' is equivalent to 'R(PauliX, θ, ϕ);'                
                let π_2 = PI()/2.;                                  // Corresponds to 45° rotation of the photon polarisation
                // The first pass through a polariser...
                set PhotonPL = M(ϕ);                                // Or: 'set PhotonPL = Measure([PauliZ], [ϕ]);'
                if(PhotonPL == One)
                {
                    // A virtual rotation of 45°
                    Ry(π_2, ϕ);    
                    // A pass throught a(n optional) second polariser...
                    if(SecondPolariser)
                    {            
                        set PhotonPL = M(ϕ);
                    }
                    if(PhotonPL == One)
                    {
                        // A virtual rotation of 45°
                        Ry(π_2, ϕ);                
                        // The final (third (or second)) pass...
                        set PhotonPL = M(ϕ);
                        if(PhotonPL == One)
                        {
                            set MacPhotons += 0b1; // O-Be-One...
                        }
                    }
                }
                Reset(ϕ); 
            }
            let quantile =  DoubleAsStringWithFormat(100. * IntAsDouble(MacPhotons)/IntAsDouble(AllPhotons), "N0");
            Message($"{MacPhotons} of {AllPhotons}... That's about {quantile}% of lucky photons!");
        }
    }
}

namespace TPR 
{
    @EntryPoint()
    operation ThreePolarisersExperiment(AllPhotons: Int, SecondPolariser: Bool) : Unit 
    {
        let tuple = ThreePeat(AllPhotons, 45.0, SecondPolariser);
        TriplePolariser(tuple);
    }
}