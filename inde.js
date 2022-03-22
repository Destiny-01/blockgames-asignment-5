let web3;
let accounts;
let contract;

const getWeb3 = () => {
  return new Promise((resolve, reject) => {
    window.addEventListener("load", async () => {
      if (window.ethereum) {
        web3 = new Web3(window.ethereum);
        accounts = await web3.eth.getAccounts();
        contract = await getContract(web3);
        try {
          // ask user permission to access his accounts
          await window.ethereum.request({ method: "eth_requestAccounts" });
          resolve(web3);
        } catch (error) {
          reject(error);
        }
      } else {
        reject("must install MetaMask");
      }
    });
  });
};

const getContract = async (web3) => {
  const data = await $.getJSON("./abi.json");

  const contract = new web3.eth.Contract(
    data,
    "0x244d5cff7c3c198ecb18f4396d66d4768f8edd37"
  );
  return contract;
};

const totalStakes = async () => {
  const stake = await contract.methods.totalStakes().call();
  $("#totalStakes").html(" " + stake);
};

const tokenBalance = async () => {
  const balance = await contract.methods.balanceOf(accounts[0]).call();
  $("#totalBalance").html(" " + balance);
};

const buyToken = async () => {
  try {
    await contract.methods.buyToken(accounts[0]).send({
      from: accounts[0],
      gas: 40000,
      value: web3.utils.toWei(String($("#token").val()), "wei"),
    });
    tokenBalance();
  } catch (err) {
    console.log(err);
  }
};

const stake = async () => {
  try {
    console.log("start");

    await contract.methods.createStake($("#stake").val()).send({
      from: accounts[0],
      gas: 100000,
    });
    await totalStakes();
    console.log("gift");
  } catch (err) {
    console.log(err);
  }
};

async function start() {
  await getWeb3();
  console.log(web3);
  console.log(accounts);
  console.log(contract);

  totalStakes();
  tokenBalance();
}

// async function start2() {
//   start();
//   console.log(web3);
//   console.log(accounts);

//   totalStakes();
//   tokenBalance();
// }

start();
