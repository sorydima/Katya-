# Blockchain Integration

## Поддерживаемые блокчейны

### Polkadot
- **Описание**: Межцепочечная совместимость для передачи сообщений и данных.
- **Интеграция**: Мосты для кросс-чейн сообщений.

### Ethereum
- **Описание**: Смарт-контракты и NFT интеграция.
- **Интеграция**: Web3Dart для взаимодействия с Ethereum.

### REChain
- **Описание**: Кастомный блокчейн для Katya.

## Конфигурация

### Polkadot
```json
{
  "endpoint": "wss://rpc.polkadot.io",
  "bridge": "polkadot-bridge"
}
```

### Ethereum
```json
{
  "rpcUrl": "https://mainnet.infura.io/v3/YOUR_PROJECT_ID",
  "chainId": 1
}
```

## API

### Bridge API
```dart
class BlockchainBridge {
  Future<void> sendMessageToChain(String message);
  Future<String> receiveFromChain();
}
```

## Безопасность
- E2E шифрование для транзакций.
- Проверка устройств для мостов.
