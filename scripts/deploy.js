// scripts/deploy.js

async function main() {
    // ethers está inyectado por Hardhat
    const [ deployer ] = await ethers.getSigners();
    console.log("Desplegando con cuenta:", deployer.address);

    // 1) Obtener la factory
    const Factory = await ethers.getContractFactory("BaseElection");

    // 2) Lanzar la transacción de deploy
    const election = await Factory.deploy();

    // 3) Esperar a que se mine
    await election.waitForDeployment();

    // 4) Mostrar la dirección (en v6 es .target)
    console.log("BaseElection desplegado en:", election.target);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
