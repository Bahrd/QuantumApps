// See e.g.: https://docs.microsoft.com/en-us/azure/quantum/tutorial-qdk-quantum-random-number-generator?tabs=tabid-qsharp

// Next step: https://en.wikipedia.org/wiki/BB84

namespace Quantum.QRNG
{
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;

    operation QuantumRandomBit() : Result
	{
        // Allocate a qubit
        use q = Qubit()
		{
			// Put the qubit to superposition
			// It now has a 50% chance of being measured 0 or 1
			H(q);

			// Measure the qubit value and reset qubit to the |0〉 state.
            let randBit = M(q); Reset(q);
            // Qubits must be in the |0〉 state by the time they are released.
			return randBit;
		}
    }

    @EntryPoint()
    operation SampleRandomNumberInRange() : Int
	{
        let max = 16;
        mutable output = 0;
        repeat
		{
            mutable bits = [Zero, size = 0];
            for idxBit in 1..BitSizeI(max)
			{
                set bits += [QuantumRandomBit()];
            }
            set output = ResultArrayAsInt(bits);
        }
		until (output <= max);
        Message($"A random number from a U[0, {max}] distribution: {output}");
        return output;
    }
}