/*
    Copyright 2017 Phillip A. Elsasser

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.4.18;

import "market-solidity/contracts/oraclize/oraclizeAPI.sol";
import "market-solidity/contracts/libraries/MathLib.sol";

/// @title QueryTest small contract to allow users to test query structure prior to contract deployment
/// @author Phil Elsasser <phil@marketprotcol.io>
contract QueryTest is usingOraclize {
    using MathLib for uint;

    // constants
    uint constant public QUERY_CALLBACK_GAS = 100000;

    // state variables
    mapping(bytes32 => bool) validScheduledQueryIDs;
    mapping(bytes32 => string) queryResults;

    // events
    event QueryCompleted(bytes32 indexed queryIDCompleted);

    /*
    // PUBLIC METHODS
    */

    /// @notice allows a user to create a query and get a callback asap as to the result to ensure their query
    /// is structured as expected
    /// @param oracleDataSource a data-source such as "URL", "WolframAlpha", "IPFS"
    /// see http://docs.oraclize.it/#ethereum-quick-start-simple-query
    /// @param oracleQuery see http://docs.oraclize.it/#ethereum-quick-start-simple-query for examples
    /// @return unique identifier to allow them to retrieve the query results once completed.
    function testOracleQuery(string oracleDataSource, string oracleQuery) external payable returns (bytes32) {
        uint cost = oraclize_getPrice(oracleDataSource).add(QUERY_CALLBACK_GAS);
        require(msg.value >= cost); // user must pay enough to cover query and callback
        bytes32 queryId = oraclize_query(
            oracleDataSource,
            oracleQuery,
            QUERY_CALLBACK_GAS
        );
        validScheduledQueryIDs[queryId] = true;
        return queryId;
    }

    /// @notice only public for callbacks from oraclize, do not call
    /// @param queryID of the returning query, this should match our own internal mapping
    /// @param result query to be processed
    /// @param proof result proof
    function __callback(bytes32 queryID, string result, bytes proof) public {
        require(msg.sender == oraclize_cbAddress());
        require(validScheduledQueryIDs[queryID]);
        delete validScheduledQueryIDs[queryID];
        queryResults[queryID] = result; //save result
        QueryCompleted(queryID);    // fire event so user can retrieve the result.
    }

}
