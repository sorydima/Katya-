import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

class BlockchainService {
  static const String _infuraKey = String.fromEnvironment('INFURA_KEY', defaultValue: 'your_infura_key');
  static const String _ethereumUrl = 'https://mainnet.infura.io/v3/$_infuraKey';

  late Web3Client _client;

  BlockchainService() {
    _client = Web3Client(_ethereumUrl, http.Client());
  }

  Future<String> getBalance(String address) async {
    final ethAddress = EthereumAddress.fromHex(address);
    final balance = await _client.getBalance(ethAddress);
    return balance.getInEther.toString();
  }

  Future<String> sendTransaction(String privateKey, String to, double amount) async {
    final credentials = await _client.credentialsFromPrivateKey(privateKey);
    final ethAmount = EtherAmount.fromUnitAndValue(EtherUnit.ether, amount);
    final transaction = Transaction(
      to: EthereumAddress.fromHex(to),
      value: ethAmount,
    );

    final txHash = await _client.sendTransaction(credentials, transaction, chainId: 1);
    return txHash;
  }

  void dispose() {
    _client.dispose();
  }
}
