pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BaseElection is Ownable {
    // @title BaseElection
    // @notice Contrato base para una elección con fases de commit-reveal
    // @dev Implementa la lógica de commit-reveal para votaciones, permitiendo registrar votos de forma anónima y segura.


    // CONSTRUCTOR
    /// @notice Inicializa el contrato asignando el owner a quien despliega
    constructor() Ownable(msg.sender) {}


    // ESTRUCTURAS
    /// @notice Representa un candidato en la elección
    struct Candidate {  // @notice Representa un candidato en la elección
        string name;
        uint256 votes;
    }

    // VARIABLES DE ESTADO
    /// @notice Lista de candidatos
    Candidate[] public candidates;
    mapping(address => bool) public hasVoted;

    // Mapping para Commit–Reveal
    mapping(address => bytes32) public commitments;

    // Máquina de estados: fases de la elección
    enum Phase { Created, Commit, Reveal, Ended }
    Phase public phase = Phase.Created;

    // EVENTOS
    event PhaseChanged(Phase newPhase);
    event VoteCommitted(address indexed voter, bytes32 commitment);
    event VoteRevealed(address indexed voter, uint256 indexed candidateId);

    // ERRORES PERSONALIZADOS
    error AlreadyCommitted();
    error NoCommitment();
    error CommitMismatch();
    error AlreadyRevealed();

    // MODIFICADORES
    modifier inPhase(Phase p) {
        require(phase == p, "Fase incorrecta");
        _;
    }

    // FUNCIONES
    /// @notice Crea un nuevo candidato
    function createCandidate(string calldata _name)
    external
    onlyOwner
    inPhase(Phase.Created)
    {
        candidates.push(Candidate({name: _name, votes: 0}));
    }

    /// @notice Inicia la fase de commit para registrar hashes
    function startCommit()
    external
    onlyOwner
    inPhase(Phase.Created)
    {
        phase = Phase.Commit;
        emit PhaseChanged(phase);
    }

    /// @notice Registra un hash de voto para revelar más tarde
    /// @param _commitment Hash del voto, generado como keccak256(abi.encodePacked(candidateId, salt))
    function commitVote(bytes32 _commitment)
    external
    inPhase(Phase.Commit)
    {
        if (commitments[msg.sender] != bytes32(0)) revert AlreadyCommitted();
        commitments[msg.sender] = _commitment;
        emit VoteCommitted(msg.sender, _commitment);
    }

    /// @notice Avanza a la fase de reveal para desvelar votos
    function startReveal()
    external
    onlyOwner
    inPhase(Phase.Commit)
    {
        phase = Phase.Reveal;
        emit PhaseChanged(phase);
    }

    /// @notice Revela tu voto y lo contabiliza
    /// @param _candidateId Índice del candidato
    /// @param _salt Valor secreto usado en el commit
    function revealVote(uint256 _candidateId, bytes32 _salt)
    external
    inPhase(Phase.Reveal)
    {
        bytes32 c = commitments[msg.sender];
        if (c == bytes32(0)) revert NoCommitment();
        if (keccak256(abi.encodePacked(_candidateId, _salt)) != c) revert CommitMismatch();
        if (hasVoted[msg.sender]) revert AlreadyRevealed();

        // Contabiliza el voto
        candidates[_candidateId].votes += 1;
        hasVoted[msg.sender] = true;

        // Limpia el commitment para gas refund
        delete commitments[msg.sender];

        emit VoteRevealed(msg.sender, _candidateId);
    }

    /// @notice Finaliza la elección
    function endVoting()
    external
    onlyOwner
    inPhase(Phase.Reveal)
    {
        phase = Phase.Ended;
        emit PhaseChanged(phase);
    }

    /// @notice Obtiene un candidato (solo tras finalizar)
    /// @param _id Índice del candidato
    function getCandidate(uint256 _id)
    external
    view
    inPhase(Phase.Ended)
    returns (Candidate memory)
    {
        require(_id < candidates.length, "Id invalido");
        return candidates[_id];
    }

    /// @notice Devuelve el número total de candidatos
    function totalCandidates()
    external
    view
    returns (uint256)
    {
        return candidates.length;
    }

    /// @notice Devuelve todos los resultados (solo tras finalizar)
    function getResults()
    external
    view
    inPhase(Phase.Ended)
    returns (Candidate[] memory)
    {
        return candidates;
    }

    /// @notice Determina el ganador (solo tras finalizar)
    function winner()
    external
    view
    inPhase(Phase.Ended)
    returns (uint256 winnerId)
    {
        uint256 highest = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].votes > highest) {
                highest = candidates[i].votes;
                winnerId = i;
            }
        }
    }
}
