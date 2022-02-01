/// # Summary
/// 
namespace DJ // A scratchpad area...
{
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Logical;
    open Microsoft.Quantum.Random;

    operation SetRealAmplitudes((α: Double, β: Double), ψ: Qubit): Unit is Adj
    {
        let ρ = β > 0.0 ? 2.0*ArcCos(α) | 2.0*ArcSin(α) - PI();
        Ry(ρ, ψ);
    }
        operation twoqub() : Bool
    {   
        use (ψ, ϕ) = (Qubit(), Qubit()) // Allocate a qubit pair
        {    
            let (α, β) = (0.6, -0.8);  // Make sure that '√(α² + β²) == 1.0';
            SetRealAmplitudes((α, β), ψ);
            DumpMachine(());

            // Measurement!
            let (m, n) = (M(ψ) == One ? 1 | 0, M(ϕ) == One ? 1 | 0);
            DumpMachine(((())));

            Message($"A state |{2*n + m}> (i.e. |{n}{m}> or |{n}>⊗|{m}>) was swiftly detected by a[n un]conscious observer!"); 
            Reset(ϕ); Reset(ψ); 
            return m == n;
        }
    }

    operation enttst(bits: Int) : Bool
    {   
        use ψ = Qubit[bits] // Allocate a qubit
        {    
            H(ψ[0]);
            DumpRegister((), ψ);
            //H(ψ[1]);
            CNOT(ψ[0], ψ[1]);
            DumpRegister((), ψ);
            X(ψ[0]);
            //ApplyToEach(H, ψ);
            DumpRegister((), ψ);

            //for i in 0..bits - 2
            //{
            //    CNOT(ψ[i], ψ[i + 1]);
            //}
            //ApplyCNOTChain(ψ);
            //DumpRegister((), ψ);
            
            //let (b, d) = (DrawRandomInt(0, bits/2 - 1), DrawRandomInt(bits/2, bits - 1));
            let (m, n) = (ResultAsBool(M(ψ[0])), ResultAsBool(M(ψ[1])));

            DumpRegister((), ψ);
            Message($"qubit #0 = {m} and qubit #1 = {n}"); 
            ResetAll(ψ); 
            return Xor(m, n);
        }
    }

    operation qqfftt(bits: Int, bit: Int) : Int
    {   
        use ψ = Qubit[bits] // Allocate a qubit register
        {    
            let ϕ = LittleEndian(ψ);
            //X(ψ[bit]); 
            //CNOT(ψ[bit], ψ[0]);
            ApplyToEach(H, ψ);
            DumpRegister((), ψ);
            //ApplyCNOTChain(ψ);
            //DumpRegister((), ψ);
            
            QFTLE(ϕ);
            DumpRegister("./state.txt", ψ);
            
            let m = MeasureInteger(ϕ);
            DumpRegister((()), ψ);
            return m;
        }
    }

}
namespace DJ
{
    operation oracle() : Bool
    {   
        use (ϕ, ψ) = (Qubit(), Qubit()) // Allocate a qubit pair
        {    
            // See: https://en.wikipedia.org/wiki/Controlled_NOT_gate#/media/File:CNOT-QuantumComputation.png
            X(ψ);
            Message("Flip ψ");
            DumpMachine(());
            H(ϕ); H(ψ);
            Message("Hadamard ϕ & ψ");
            DumpMachine(());
            CNOT(ϕ, ψ);
            Message("Entangle ϕ & ψ");
            DumpMachine(());
            H(ϕ); 
            Message("Hadamard ϕ");
            DumpMachine(());
            
            // Housekeeping...
            let b = M(ϕ) == One;
            Message($"Measure of {ϕ} yields {b}");
            DumpMachine(());
            Reset(ϕ); Reset(ψ); 
            Message("Rise and clean");
            DumpMachine(());
            return b;
		}
    }
}
namespace DJ 
{
    @EntryPoint()
    operation EntanglementTest() : Unit 
    {
        let b = oracle();
        Message($"|ϕ> = {b}");
    }
}
    
// References    
// H(ψ); return M(ψ);       // Yet another oneliner... 
// ¿Does it hold water: H(ψ) ≡ R(PauliX, π/2, ψ) ≠ R(PauliY, π/2, ψ)?   
// https://en.wikipedia.org/wiki/Bloch_sphere#/media/File:Bloch_sphere.svg 
// https://docs.microsoft.com/en-us/quantum/concepts/pauli-measurements
// dotnet build --no-restore --nologo; $pi = [math]::pi; for($i = 10; $i -le 10; $i++){ dotnet run --no-build --bits $i --pauli-r PauliY --theta $pi --pauli-m PauliZ}