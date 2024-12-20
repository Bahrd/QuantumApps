namespace vsq
{

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation VanillaTeleport() : Result
    {
        use (q0, q1, q2) = (Qubit(), Qubit(), Qubit());

        // A: Turn superposition into entanglement
        H(q1); CNOT(q1, q2);

        // Me: Set the state to be teleported
        //let π = Microsoft.Quantum.Math.PI(); Rx(π/4.0, q0);
        H(q0);
        // A: Bell measurement
        CNOT(q0, q2); H(q0);
        let (m1, m2) = (M(q1) == One, M(q0) == One);

        // A: Transmit (m1, m2) to Bob (e.g. via SMS)

        // B: Recover the state
        if (m1) { X(q2); }
        if (m2) { Z(q2); }
        // B: Measure a teleported qubit state (if necessary)
        let Bob = M(q2);
        Message($"Bob's outcome: {Bob}");

        Reset(q0); Reset(q1); Reset(q2);
        return Bob;
    }
}
