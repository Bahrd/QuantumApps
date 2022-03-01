// See e.g.: https://docs.microsoft.com/en-us/azure/quantum/tutorial-qdk-quantum-random-number-generator?tabs=tabid-qsharp
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
			// Measure the qubit value            
			return M(q);
		}
    }
}

namespace Quantum.QRNG 
{
    @EntryPoint() // dotnet watch run --max 32
    operation SampleRandomNumberInRange(max : Int) : Int 
	{
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
        return output;
    }
}