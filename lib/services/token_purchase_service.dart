import 'package:http/http.dart' as http;
import 'package:katya/global/constants.dart';
import 'package:katya/providers/web3_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';

class TokenPurchaseService {
  final Web3Provider _web3Provider;
  final String _rpcUrl;
  late Web3Client _web3client;

  // DEX and marketplace router addresses
  static const Map<String, String> DEX_ROUTERS = {
    '1': '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D', // Uniswap V2 Router
    '56': '0x10ED43C718714eb63d5aA57B78B54704E256024E', // PancakeSwap Router
    '137': '0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff', // QuickSwap Router
  };

  // Chain native tokens
  static const Map<String, String> NATIVE_TOKENS = {
    '1': '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE', // ETH
    '56': '0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c', // BNB
    '137': '0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270', // MATIC
  };

  TokenPurchaseService(this._web3Provider, {String? rpcUrl}) : _rpcUrl = rpcUrl ?? DEFAULT_RPC_URL {
    _web3client = Web3Client(_rpcUrl, http.Client());
  }

  /// Gets the best price for a token swap
  Future<BigInt> getBestPrice({
    required String tokenIn,
    required String tokenOut,
    required BigInt amountIn,
  }) async {
    try {
      // This is a simplified example - in a real app, you'd query DEX aggregators
      // like 1inch, 0x API, or directly query DEX contracts

      // For now, we'll return a mock price
      // In a real implementation, you would:
      // 1. Query multiple DEXs/aggregators
      // 2. Find the best price
      // 3. Return the expected amount out

      // Mock implementation - returns 1:1 for testing
      return amountIn;
    } catch (e) {
      print('Error getting price: $e');
      rethrow;
    }
  }

  /// Swaps tokens using the best available DEX
  Future<String> swapTokens({
    required String tokenIn,
    required String tokenOut,
    required BigInt amountIn,
    double slippage = 0.5, // 0.5% slippage
  }) async {
    try {
      final chainId = _web3Provider.chainId;
      if (chainId == null) throw Exception('Not connected to a network');

      final routerAddress = DEX_ROUTERS[chainId];
      if (routerAddress == null) {
        throw Exception('Unsupported network for token swaps');
      }

      final router = DeployedContract(
        ContractAbi.fromJson(_getRouterABI(), 'IUniswapV2Router02'),
        EthereumAddress.fromHex(routerAddress),
      );

      final tokenInAddress = EthereumAddress.fromHex(tokenIn);
      final tokenOutAddress = EthereumAddress.fromHex(tokenOut);

      // Get the expected amount out with slippage
      final amountOutMin = await getBestPrice(
        tokenIn: tokenIn,
        tokenOut: tokenOut,
        amountIn: amountIn,
      );

      final amountOutWithSlippage = amountOutMin * BigInt.from(1000 - (slippage * 10).toInt()) ~/ BigInt.from(1000);

      // Get deadline (20 minutes from now)
      final deadline = (DateTime.now().millisecondsSinceEpoch / 1000).round() + 1200;

      // Get the swap parameters
      final params = [
        amountIn,
        amountOutWithSlippage,
        [tokenInAddress, tokenOutAddress],
        _web3Provider.ethereumAddress,
        BigInt.from(deadline),
      ];

      // Create transaction
      final swapFunction = router.function('swapExactTokensForTokens');
      final tx = Transaction.call(
        contract: router,
        function: swapFunction,
        parameters: params,
      );

      // Send transaction
      final credentials = await _web3Provider.getCredentials();
      final txHash = await _web3client.sendTransaction(
        credentials,
        tx,
        chainId: int.parse(chainId),
      );

      return txHash;
    } catch (e) {
      print('Error swapping tokens: $e');
      rethrow;
    }
  }

  /// Buys an NFT from a marketplace
  Future<String> buyNFT({
    required String marketplaceAddress,
    required String nftAddress,
    required BigInt tokenId,
    BigInt? price,
  }) async {
    try {
      // In a real implementation, this would interact with the marketplace contract
      // For now, we'll return a mock transaction hash

      // Example for OpenSea Seaport (simplified)
      final marketplace = DeployedContract(
        ContractAbi.fromJson(_getSeaportABI(), 'Seaport'),
        EthereumAddress.fromHex(marketplaceAddress),
      );

      // This is a simplified example - actual implementation would be more complex
      // and depend on the specific marketplace contract

      final tx = Transaction.call(
        contract: marketplace,
        function: marketplace.function('fulfillOrder'),
        parameters: [
          // Order parameters would go here
        ],
      );

      final credentials = await _web3Provider.getCredentials();
      final txHash = await _web3client.sendTransaction(
        credentials,
        tx,
        chainId: int.parse(_web3Provider.chainId ?? '1'),
      );

      return txHash;
    } catch (e) {
      print('Error buying NFT: $e');
      rethrow;
    }
  }

  /// Opens a token in a DEX for swapping
  Future<void> openInDex({
    required String tokenAddress,
    String? tokenSymbol,
  }) async {
    try {
      final chainId = _web3Provider.chainId ?? '1';
      String url;

      switch (chainId) {
        case '1': // Ethereum Mainnet
          url = 'https://app.uniswap.org/#/swap?inputCurrency=ETH&outputCurrency=$tokenAddress';
        case '56': // BSC
          url = 'https://pancakeswap.finance/swap?outputCurrency=$tokenAddress';
        case '137': // Polygon
          url = 'https://quickswap.exchange/#/swap?outputCurrency=$tokenAddress';
        default:
          throw Exception('Unsupported network for DEX integration');
      }

      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw Exception('Could not launch DEX');
      }
    } catch (e) {
      print('Error opening DEX: $e');
      rethrow;
    }
  }

  /// Opens an NFT in a marketplace
  Future<void> openInMarketplace({
    required String nftAddress,
    required BigInt tokenId,
    String? marketplace = 'opensea', // 'opensea', 'looksrare', etc.
  }) async {
    try {
      final chainId = _web3Provider.chainId ?? '1';
      String baseUrl;

      switch (marketplace?.toLowerCase()) {
        case 'opensea':
          baseUrl = chainId == '1'
              ? 'https://opensea.io/assets/ethereum/$nftAddress/$tokenId'
              : 'https://testnets.opensea.io/assets/$nftAddress/$tokenId';
        case 'looksrare':
          baseUrl = 'https://looksrare.org/collections/$nftAddress/$tokenId';
        default:
          throw Exception('Unsupported marketplace');
      }

      if (await canLaunch(baseUrl)) {
        await launch(baseUrl);
      } else {
        throw Exception('Could not launch marketplace');
      }
    } catch (e) {
      print('Error opening marketplace: $e');
      rethrow;
    }
  }

  // Helper methods for ABI and encoding
  String _getRouterABI() {
    return '''
      [
        {
          "inputs": [
            {"internalType": "uint256", "name": "amountIn", "type": "uint256"},
            {"internalType": "uint256", "name": "amountOutMin", "type": "uint256"},
            {"internalType": "address[]", "name": "path", "type": "address[]"},
            {"internalType": "address", "name": "to", "type": "address"},
            {"internalType": "uint256", "name": "deadline", "type": "uint256"}
          ],
          "name": "swapExactTokensForTokens",
          "outputs": [{"internalType": "uint256[]", "name": "amounts", "type": "uint256[]"}],
          "stateMutability": "nonpayable",
          "type": "function"
        }
      ]
    ''';
  }

  String _getSeaportABI() {
    return '''
      [
        {
          "inputs": [
            {"components": [
              {"components": [
                {"internalType": "address", "name": "offerer", "type": "address"},
                {"internalType": "address", "name": "zone", "type": "address"},
                {"components": [
                  {"internalType": "enum ItemType", "name": "itemType", "type": "uint8"},
                  {"internalType": "address", "name": "token", "type": "address"},
                  {"internalType": "uint256", "name": "identifierOrCriteria", "type": "uint256"},
                  {"internalType": "uint256", "name": "startAmount", "type": "uint256"},
                  {"internalType": "uint256", "name": "endAmount", "type": "uint256"}
                ], "name": "offer", "type": "tuple[]"},
                {"components": [
                  {"internalType": "enum ItemType", "name": "itemType", "type": "uint8"},
                  {"internalType": "address", "name": "token", "type": "address"},
                  {"internalType": "uint256", "name": "identifierOrCriteria", "type": "uint256"},
                  {"internalType": "uint256", "name": "startAmount", "type": "uint256"},
                  {"internalType": "uint256", "name": "endAmount", "type": "uint256"},
                  {"internalType": "address payable", "name": "recipient", "type": "address"}
                ], "name": "consideration", "type": "tuple[]"},
                {"internalType": "enum OrderType", "name": "orderType", "type": "uint8"},
                {"internalType": "uint256", "name": "startTime", "type": "uint256"},
                {"internalType": "uint256", "name": "endTime", "type": "uint256"},
                {"internalType": "bytes32", "name": "zoneHash", "type": "bytes32"},
                {"internalType": "uint256", "name": "salt", "type": "uint256"},
                {"internalType": "bytes32", "name": "conduitKey", "type": "bytes32"},
                {"internalType": "uint256", "name": "totalOriginalConsiderationItems", "type": "uint256"}
              ], "name": "parameters", "type": "tuple"},
              {"internalType": "bytes", "name": "signature", "type": "bytes"}
            ], "name": "fulfillOrder", "outputs": [], "stateMutability": "payable", "type": "function"}
          ]
        }
      ]
    ''';
  }
}
