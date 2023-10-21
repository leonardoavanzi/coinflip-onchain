// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;
import "@chainlink/contracts/src/v0.8/vrf/VRFV2WrapperConsumerBase.sol";
//VRFV2WrapperConsumerBase.
contract CoinFlip is VRFV2WrapperConsumerBase{
    event CoinFlipRequest(uint256 requestId);
    event CoinFlipResponse(uint256 requestId, bool didWin);

    struct FlipStatus {
        uint256 randomWord; //from chainlink
        uint256 fees;
        address player;
        bool didWin;
        bool fulfilled;
        CoinFlipSelection choice;

    }

    enum CoinFlipSelection {
        HEADS,
        TAILS
    }

    mapping(uint256 => FlipStatus) public status;

    address constant linkAddress = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
    address constant vrfWrapper = 0x708701a1DfF4f478de54383E49a627eD4852C816;

    uint128 constant entryFees = 0.001 ether;
    uint32 constant callbackGasLimit = 1_000_000;
    uint32 constant numWords = 1;
    uint16 constant requestConfirmations = 3; 

    constructor() payable VRFV2WrapperConsumerBase(linkAddress, vrfWrapper) {}

    function flip(CoinFlipSelection choice)
        external 
        payable 
        returns (uint256) {
        require(msg.value == entryFees, "entry fees not sent.");

        uint256 requestId = requestRandomness(callbackGasLimit, requestConfirmations, numWords);

        status[requestId] = FlipStatus({
            fees: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWord: 0,
            player: msg.sender,
            didWin: false,
            fulfilled:false,
            choice: choice

        });

        emit CoinFlipRequest(requestId);
        return requestId;

    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {

        require(status[requestId].fees > 0, "Request not found");

        status[requestId].fulfilled = true;
        status[requestId].randomWord = randomWords[0];
        CoinFlipSelection response = CoinFlipSelection.HEADS;
        if (randomWords[0] % 2 == 0) {
            response = CoinFlipSelection.TAILS;
        }

        if (status[requestId].choice == response){
            status[requestId].didWin = true;
            payable(status[requestId].player).transfer(entryFees * 2);
        }

        emit CoinFlipResponse(requestId, status[requestId].didWin);

    }

    function getStatus(uint256 requestId) public view returns (FlipStatus memory) {
        return status[requestId];

    }
}
