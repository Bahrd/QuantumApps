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
    operation θxθyθz(): TripleDouble
    {
        return TripleDouble(DRD(), DRD(), DRD());
    }
}
namespace TPR // Area 51...
{
    // A three polarisers experiment (A three obstacle photon racing...) implementation
    operation TriplePolariser(t4t: ThreePeat) : Unit
    {   
        let (AllPhotons, θ, SecondPolariser) = t4t!;
        use ϕ = Qubit()
        {    
            mutable (MacPhotons, PhotonPL) = (0b0, Zero);
            for i in 1..AllPhotons
            {
                // Making a photon polarisation a (qu)bit random...
                // ... with a little help of two ¿bad taste? one-liners!
                let (θx, θy, θz) = (θxθyθz())!;
                let (_, _, _) = (Rx(θx, ϕ), Ry(θy, ϕ), Rz(θz, ϕ));  // Where e.g. 'Rx(θx, ϕ)' is equivalent to 'R(PauliX, θx, ϕ);'                                
                let ρ = θ * PI()/90.;                               // Degree to radian conversion of the polariser's angle
                // The first pass through a polariser...
                set PhotonPL = M(ϕ);                                // Or: 'set PhotonPL = Measure([PauliZ], [ϕ]);'
                if(PhotonPL == One)
                {
                    // A virtual rotation of θ°
                    Ry(ρ, ϕ);    
                    // A pass throught a(n optional) second polariser...
                    if(SecondPolariser)
                    {            
                        set PhotonPL = M(ϕ);
                    }
                    if(PhotonPL == One)
                    {
                        // A virtual rotation of θ°
                        Ry(ρ, ϕ);                
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
    operation ThreePolarisersExperiment(AllPhotons: Int, theta: Double, SecondPolariser: Bool) : Unit 
    {
        let tuple = ThreePeat(AllPhotons, theta, SecondPolariser);
        TriplePolariser(tuple);
    }
}