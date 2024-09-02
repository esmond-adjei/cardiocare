import 'dart:developer' as dev;
import 'package:cardiocare/signal_app/widgets/ai_analysis.dart';
import 'package:cardiocare/signal_app/widgets/share_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cardiocare/signal_app/model/signal_enums.dart';
import 'package:cardiocare/signal_app/widgets/signal_renderers.dart';
import 'package:cardiocare/services/db_helper.dart';
import 'package:cardiocare/signal_app/model/signal_model.dart';
import 'package:cardiocare/utils/format_datetime.dart';

class ListItem extends StatelessWidget {
  final Signal signal;
  final Function(Signal) onDismissed;

  const ListItem({super.key, required this.signal, required this.onDismissed});

  String _getSignalHighlight() {
    switch (signal.signalType) {
      case SignalType.ecg:
        return '${(signal as EcgModel).hbpm} bpm';
      case SignalType.bp:
        final sig = signal as BpModel;
        return '${sig.systolic}/${sig.diastolic} mmHg';
      case SignalType.btemp:
        return '${(signal as BtempModel).avgTemp.toStringAsFixed(1)} °C';
      default:
        return 'Unknown';
    }
  }

  void _showPeakDrawer(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5, // Start at 50% of the screen height
        minChildSize: 0.2, // Minimum height (20% of screen)
        maxChildSize: 1.0, // Can expand to full screen
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: PeakItemDrawer(signal: signal), // called by this widget
          ),
        ),
      ),
    );
  }

  Future<void> _deleteSignal(BuildContext context) async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    dev.log("deleting signal: ${signal.id} from ${signal.signalType}");
    try {
      await dbHelper.deleteSignal(signal);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${signal.name} deleted successfully")),
      );
      onDismissed(signal);
    } catch (e) {
      dev.log(">> error deleting signal: $e");
    }
  }

  Future<bool?> _confirmDelete(BuildContext context, DatabaseHelper dbHelper) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          title: Text("Delete ${signal.name}?"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("CANCEL"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("DELETE"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbHelper = Provider.of<DatabaseHelper>(context);

    return Dismissible(
      key: Key(signal.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: signal.signalType.color,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      onDismissed: (_) => _deleteSignal(context),
      confirmDismiss: (_) => _confirmDelete(context, dbHelper),
      child: ListTile(
        tileColor: Theme.of(context).colorScheme.secondary,
        iconColor: signal.signalType.color,
        splashColor: signal.signalType.color.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        onTap: () => _showPeakDrawer(context),
        leading: _buildLeadingIcon(),
        title: _buildTitle(context),
        subtitle: _buildSubtitle(),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: signal.signalType.color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(child: signal.signalType.icon),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            signal.name,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
            decoration: BoxDecoration(
              color: signal.signalType.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getSignalHighlight(),
              style: TextStyle(
                fontSize: 12,
                color: signal.signalType.color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            formatDuration(signal.startTime.toIso8601String(),
                signal.stopTime.toIso8601String()),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Text(
          formatDateTime(signal.startTime.toIso8601String()),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class PeakItemDrawer extends StatefulWidget {
  final dynamic signal;

  const PeakItemDrawer({super.key, required this.signal});

  @override
  State<PeakItemDrawer> createState() => _PeakItemDrawerState();
}

class _PeakItemDrawerState extends State<PeakItemDrawer> {
  final TextEditingController _controller = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.signal.name;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _updateSignalName(DatabaseHelper dbhelper) async {
    String prevSignalName = widget.signal.name;
    widget.signal.name = _controller.text;
    if (await dbhelper.updateSignal(widget.signal) == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "$prevSignalName updated to ${widget.signal.name} successfully")),
      );
    }
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final dbhelper = Provider.of<DatabaseHelper>(context);

    return SingleChildScrollView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(dbhelper),
            const SizedBox(height: 16),
            _buildSignalContent(),
            const SizedBox(height: 16),
            AIAnalysis(signal: widget.signal),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DatabaseHelper dbhelper) {
    return Row(
      children: [
        Expanded(
          child: _isEditing
              ? TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: "Signal Name",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(4),
                  ),
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.bold),
                  autofocus: true,
                )
              : Text(
                  widget.signal.name,
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
        ),
        IconButton(
          icon: Icon(_isEditing ? Icons.done : Icons.edit),
          onPressed: () => _isEditing
              ? _updateSignalName(dbhelper)
              : setState(() => _isEditing = true),
        ),
        if (_isEditing)
          IconButton(
            icon: const Icon(Icons.close_sharp),
            onPressed: () => setState(() {
              _isEditing = false;
              _controller.text = widget.signal.name;
            }),
          ),

        // SHARE BUTTON
        ShareButton(
          shareText:
              'Checkout my ${widget.signal.signalType} data from the CardioCare App',
          signal: widget.signal,
          child: _buildSignalContent(),
        )
      ],
    );
  }

  Widget _buildSignalContent() {
    switch (widget.signal.signalType) {
      case SignalType.ecg:
        return ECGRenderer(isActive: true, ecgSignal: widget.signal);
      case SignalType.bp:
        return BPRenderer(isActive: true, bpSignal: widget.signal);
      case SignalType.btemp:
        return BtempRenderer(isActive: true, btempSignal: widget.signal);
      default:
        return const Center(child: Text("Unable to render signal data"));
    }
  }
}
