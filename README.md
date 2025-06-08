# Sistema de Votacion Descentralizado


Este repositorio contiene el contrato inteligente [BaseElection](contracts/BaseElection.sol) escrito en Solidity para realizar votaciones utilizando el patrón **Commit-Reveal** en una blockchain basado en Ethereum.

## Objetivo

Implementar un sistema descentralizado de elecciones seguro, transparente y anónimo utilizando dos fases claramente diferenciadas: **commit** y **reveal**.

## Características clave

* **Transparencia**: Cada fase y operación queda registrada en la blockchain.
* **Anonimato**: Los votos se cifran durante la fase inicial.
* **Integridad**: Validación mediante hashes para prevenir modificaciones.
* **Gestión de fases**: Automatización de los procesos electorales (inicio, votación, revelación y finalización).

## Instalación y uso

### Requisitos

* Node.js y npm instalados.
* Remix IDE o cualquier entorno de desarrollo compatible con Solidity.
* OpenZeppelin (para `Ownable`)

### Uso

1. **Desplegar el Contrato**:
   Utiliza Remix IDE o Hardhat para desplegar el contrato en la red deseada (local o testnet).


2. **Registrar Candidatos**:
   Durante la fase `Created`, el propietario (`owner`) registra candidatos:

   ```solidity
   createCandidate("Nombre del Candidato");
   ```

3. **Fase Commit**:
   Iniciar la fase commit:

   ```solidity
   startCommit();
   ```

   Los votantes registran sus compromisos (`commitVote`) enviando un hash generado con el voto y un valor secreto (salt):

   ```solidity
   commitVote(hash);
   ```

4. **Fase Reveal**:
   Iniciar la fase de revelación:

   ```solidity
   startReveal();
   ```

   Revelar el voto original junto al salt:

   ```solidity
   revealVote(candidateId, salt);
   ```

5. **Finalizar la Elección**:

   ```solidity
   endVoting();
   ```

   Consultar resultados:

   ```solidity
   getResults();
   winner();
   ```

## Seguridad

Este contrato utiliza el patrón Commit-Reveal para proteger la privacidad del votante y la integridad de la elección.