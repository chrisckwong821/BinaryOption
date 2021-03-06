pragma solidity ^0.6.7;

interface BinaryOptionInterface {

  function IsExercised(uint ID) external view returns (bool);
  function IsExpiried(uint ID) external view returns (bool);
  function IsBought(uint ID) external view returns (bool);
  
}
