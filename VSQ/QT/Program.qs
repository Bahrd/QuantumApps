// See: https://learn.microsoft.com/en-us/training/modules/explore-entanglement/5-create-teleportation-qsharp
namespace QVT
{
    @EntryPoint()
    operation VanillaTeleport() : Result
    {
        let (teleportation, transmission) = (true, true);
        use (msg, Alice, Bob) = (Qubit(), Qubit(), Qubit());

        // A: Her qubit can be in any state, it seems...
        let π = Microsoft.Quantum.Math.PI();
        Rx(π/3.0, Alice); Ry(π/4.0, Alice); Rz(π/2.0, Alice);

        // A: Turn superposition into entanglement
        H(Alice); CNOT(Alice, Bob);
        // Me: Set the state to be teleported
        X(msg);

        if(teleportation)
        {
            // A: Bell measurement, a.k.a. entanglement swapping
            CNOT(msg, Alice); H(msg);
            let (A, B) = (M(Alice) == One, M(msg) == One);

            if(transmission)
            {
                // A: Transmit (A, B) to Bob (e.g. via SMS)
                Message($"2 bits 2 Bob: {(A, B)}");
                // B: Recover the state
                if (A) { X(Bob); } if (B) { Z(Bob); }
            }
        }
        // B: Measure a qubit state (whether or not it was teleported)
        let m = M(Bob); Message($"Bob's message: {m}");

        Reset(msg); Reset(Alice); Reset(Bob);
        return m;
    }
}