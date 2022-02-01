/// # A Q# implementaion of the classic (Dirac's) triple polarizer experiment 
///
/// Usage example (Windows Terminal or the other .NET Core 3.1 compatible shell): 
/// The command: 'dotnet build --no-restore --nologo; dotnet run --no-build --all-photons 4096 --second-polariser true --theta 45'
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
    operation θxyz(): TripleDouble
    {
        return TripleDouble(DRD(), DRD(), DRD());
    }
    operation Rxyz(θ: TripleDouble, ϕ: Qubit): Unit
    {
        let (θx, θy, θz) = θ!;
        // ... with a little help of a ¿bad taste? one-liner!
        let (_, _, _) = (Rx(θx, ϕ), Ry(θy, ϕ), Rz(θz, ϕ));  // 'R*(θ*, ϕ)' is equivalent to 'R(Pauli*, θ*, ϕ);'                                
    }
}
namespace TPR // Area 51...
{
    // A three polarisers experiment (kinda like a photon steeplechase...) implementation
    operation TriplePolariser(thp: ThreePeat) : Unit
    {   
        let (AllPhotons, θ, SecondPolariser) = thp!;
        use ϕ = Qubit()
        {    
            mutable (MacPhotons, PhotonPL) = (0b0, Zero);
            for _ in 1..AllPhotons
            {
                // Making a photon polarisation a (qu)bit random...
                Rxyz(θxyz(), ϕ);
                //Preparing the polarisers...
                let ρ = θ * PI()/90.;   // Degree to radian conversion of the polariser's angle
                
                // The first attempt to pass through a polariser...
                set PhotonPL = M(ϕ);    // Or: 'set PhotonPL = Measure([PauliZ], [ϕ]);'
                if(PhotonPL == One)
                {
                    // A virtual rotation of θ° (in this way we model rotation of a polariser)
                    Ry(ρ, ϕ);    
                    // An attempt to pass throught a(n optional) second polariser...
                    if(SecondPolariser)
                    {            
                        set PhotonPL = M(ϕ);
                    }
                    if(PhotonPL == One)
                    {
                        // A virtual rotation of θ° (of another polariser)
                        Ry(ρ, ϕ);                
                        // The final (third (or second)) attempt...
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
    operation ThreePolarisersExperiment(AllPhotons: Int, theta: Double, SecondPolariser: Bool) : Unit 
    {
        let tuple = ThreePeat(AllPhotons, theta, SecondPolariser);
        TriplePolariser(tuple);
    }
}