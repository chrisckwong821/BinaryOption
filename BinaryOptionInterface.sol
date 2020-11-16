pragma solidity ^0.6.7;

interface BinaryOptionInterface {

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function IsExercised(uint ID) external view returns (bool);
}
