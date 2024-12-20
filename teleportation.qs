
use (Λ, ψ, Φ) = (Qubit(), Qubit(), Qubit());

H(Φ); CNOT(Φ, ψ);

CNOT(Λ, ψ); H(Λ);
let (m1, m2) = (M(Φ) == One, M(Λ) == One);

if (m1) { X(ψ); } if (m2) { Z(ψ); }
Message($"ψ: {M(ψ)}");

Reset(Λ); Reset(Φ); Reset(ψ);