// scripts/generateCommit.js

import Web3 from "web3";

const web3 = new Web3();

// Leer argumentos desde la consola
// Uso: node scripts/generateCommit.js <candidateId> [saltHex]
const [idArg, saltArg] = process.argv.slice(2);

// Verifica que se haya pasado un ID de candidato
if (!idArg) {
  console.error("Uso: node scripts/generateCommit.js <candidateId> [saltHex]");
  process.exit(1);
}

const candidateId = parseInt(idArg, 10);

// Verifica que el ID sea un número válido
if (isNaN(candidateId)) {
  console.error("Error: <candidateId> debe ser un número entero válido.");
  process.exit(1);
}

// Usa un salt proporcionado o genera uno aleatorio de 32 bytes
const salt = saltArg || web3.utils.randomHex(32);

// Codifica los datos y genera el hash (commitment)
const encoded = web3.eth.abi.encodeParameters([
  "uint256",
  "bytes32"
], [candidateId, salt]);

const commitment = web3.utils.keccak256(encoded);

// Muestra los resultados en consola
console.log("=== Parámetros del commit ===");
console.log("ID del candidato:", candidateId);
console.log("Salt:", salt);
console.log("Commitment:", commitment);
