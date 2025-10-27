import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/matrix_provider.dart';
import 'chat/matrix_chat_screen.dart';

class MatrixRoomsScreen extends StatefulWidget {
  const MatrixRoomsScreen({super.key});

  @override
  _MatrixRoomsScreenState createState() => _MatrixRoomsScreenState();
}

class _MatrixRoomsScreenState extends State<MatrixRoomsScreen> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final matrixProvider = Provider.of<MatrixProvider>(context, listen: false);

      // Make sure the client is initialized
      if (!matrixProvider.isInitialized) {
        await matrixProvider.initialize();
      }

      // The rooms are automatically loaded when the client initializes
      // and when new rooms are received via sync
    } catch (e) {
      setState(() {
        _error = 'Failed to load rooms: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createNewRoom() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _CreateRoomDialog(),
    );

    if (result != null) {
      await _handleCreateRoom(
        name: result['name'],
        isEncrypted: result['isEncrypted'],
        isDirect: result['isDirect'],
      );
    }
  }

  Future<void> _handleCreateRoom({
    String? name,
    bool isEncrypted = true,
    bool isDirect = false,
  }) async {
    final matrixProvider = Provider.of<MatrixProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await matrixProvider.createRoom(
        name: name,
        isEncrypted: isEncrypted,
        isDirect: isDirect,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create room: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _joinRoom() async {
    final roomIdOrAlias = await showDialog<String>(
      context: context,
      builder: (context) => _JoinRoomDialog(),
    );

    if (roomIdOrAlias != null && roomIdOrAlias.isNotEmpty) {
      await _handleJoinRoom(roomIdOrAlias);
    }
  }

  Future<void> _handleJoinRoom(String roomIdOrAlias) async {
    final matrixProvider = Provider.of<MatrixProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await matrixProvider.joinRoom(roomIdOrAlias);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined room')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join room: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRooms,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewRoom,
          ),
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: _joinRoom,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading rooms',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRooms,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Consumer<MatrixProvider>(
      builder: (context, matrixProvider, _) {
        final rooms = matrixProvider.getRooms();

        if (rooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.forum_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No rooms yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text('Tap + to create or join a room'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            final lastEvent = room.lastEvent;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  room.displayname.isNotEmpty ? room.displayname[0].toUpperCase() : '#',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              title: Text(
                room.displayname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: lastEvent != null
                  ? Text(
                      '${lastEvent.senderId.split(':')[0].replaceFirst('@', '')}: ${lastEvent.body}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : const Text('No messages yet'),
              trailing: room.notificationCount > 0
                  ? CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        '${room.notificationCount}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MatrixChatScreen(roomId: room.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _CreateRoomDialog extends StatefulWidget {
  const _CreateRoomDialog();

  @override
  _CreateRoomDialogState createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<_CreateRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isEncrypted = true;
  bool _isDirect = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Room'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Room Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a room name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('End-to-end Encryption'),
              subtitle: const Text('Encrypt messages for all participants'),
              value: _isEncrypted,
              onChanged: (value) {
                setState(() {
                  _isEncrypted = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Direct Message'),
              subtitle: const Text('Create a 1:1 chat'),
              value: _isDirect,
              onChanged: (value) {
                setState(() {
                  _isDirect = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              Navigator.of(context).pop({
                'name': _nameController.text.trim(),
                'isEncrypted': _isEncrypted,
                'isDirect': _isDirect,
              });
            }
          },
          child: const Text('CREATE'),
        ),
      ],
    );
  }
}

class _JoinRoomDialog extends StatefulWidget {
  @override
  _JoinRoomDialogState createState() => _JoinRoomDialogState();
}

class _JoinRoomDialogState extends State<_JoinRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _roomIdController = TextEditingController();

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join Room'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _roomIdController,
              decoration: const InputDecoration(
                labelText: 'Room ID or Alias',
                hintText: '!room:example.com or #room:example.com',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a room ID or alias';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              Navigator.of(context).pop(_roomIdController.text.trim());
            }
          },
          child: const Text('JOIN'),
        ),
      ],
    );
  }
}
