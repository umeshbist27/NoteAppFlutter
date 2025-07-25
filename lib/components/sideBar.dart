import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noteappflu/note_models/note.dart';
import 'package:html/parser.dart' as html_parser;


class SidebarWidget extends StatefulWidget {
  final Note? activeNote;
  final List<Note> notes;
  final Function(String id) onDelete;
  final VoidCallback onAddClick;
  final Function(Note) onNoteClick;
  final String username;
  final VoidCallback onLogout;

  const SidebarWidget({
    super.key,
    required this.activeNote,
    required this.notes,
    required this.onDelete,
    required this.onAddClick,
    required this.onNoteClick,
    required this.username,
    required this.onLogout,
  });

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTitle = "";
  late List<Note> filteredNotes;

  @override
  void initState() {
    super.initState();
    filteredNotes = List.from(widget.notes);
    _searchController.addListener(() {});
  }

  @override
  void didUpdateWidget(covariant SidebarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _filterNotes();
  }

  void _filterNotes() {
    List<Note> sortedNotes = List.from(widget.notes);
    sortedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    if (_searchTitle.trim().isEmpty) {
      setState(() {
        filteredNotes = sortedNotes;
      });
    } else {
      final result = sortedNotes.where((note) {
        return note.title.toLowerCase().contains(_searchTitle.toLowerCase());
      }).toList(); 

      if (result.isEmpty) {
        Fluttertoast.showToast(msg: "Note not matched");
      }

      setState(() {
        filteredNotes = result;
      });
    }
  }

  Future<void> _confirmLogout() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Logout"),
        content: Text("You’re about to log out. Continue?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Logout"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onLogout();
      Fluttertoast.showToast(msg: "User Logged Out Successfully");
    }
  }

  Future<void> _confirmDelete(String id) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Note"),
        content: Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onDelete(id);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} ${_monthShort(date.month)} ${date.year.toString().substring(2)}";
  }

  String _monthShort(int month) {
    const months = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC",
    ];
    return months[month - 1];
  }

 String _getPreviewText(String content) {
  final document = html_parser.parse(content);
  String plainText = document.body?.text.trim() ?? '';
  if (plainText.length > 100) {
    return "${plainText.substring(0, 100)}...";
  }
  return plainText;
}

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: double.infinity,
      child: Column(
        children: [
          // Header section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "My Notes",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3f3f3f),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.person, size: 20, color: Colors.grey[700]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.username,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: _confirmLogout,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(
                          Icons.logout,
                          size: 20,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: widget.onAddClick,
                  icon: Icon(Icons.add, size: 20),
                  label: Text("Add Note"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 40),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          if (widget.notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search notes...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  suffixIcon: Icon(Icons.search),
                ),
                onSubmitted: (value) {
                  setState(() {
                    _searchTitle = value.trim();
                    _filterNotes();
                  });
                },
              ),
            ),

          // Notes list
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        "No notes available\nCreate your first note to get started",
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      final isActive =
                          widget.activeNote != null &&
                          widget.activeNote!.id == note.id;

                      return GestureDetector(
                        onTap: () => widget.onNoteClick(note),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.grey[200]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDate(note.updatedAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(width: 24), 
                                ],
                              ),
                              
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      note.title.isEmpty
                                          ? "Untitled Note"
                                          : note.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => _confirmDelete(note.id),
                                  ),
                                ],
                              ),
                              // Preview content
                              Text(
                                _getPreviewText(note.content),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
