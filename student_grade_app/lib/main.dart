import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as excel;  // Add prefix here
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Student Grade Manager',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
      brightness: Brightness.light,
    ),
    darkTheme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
      brightness: Brightness.dark,
    ),
    themeMode: ThemeMode.system,
    home: const GradeManagerHomePage(),
    debugShowCheckedModeBanner: false,
  );
}

class GradeManagerHomePage extends StatefulWidget {
  const GradeManagerHomePage({super.key});

  @override
  State<GradeManagerHomePage> createState() => _GradeManagerHomePageState();
}

class _GradeManagerHomePageState extends State<GradeManagerHomePage> {
  // State variables
  List<Map<String, dynamic>> _students = [];
  String? _currentFilePath;
  bool _isLoading = false;
  String? _statusMessage;
  bool _isDarkMode = false;
  
  // Column indices
  int _nameColIndex = -1;
  int _scoreColIndex = -1;
  int _gradeColIndex = -1;
  
  // Statistics
  double _averageScore = 0.0;
  Map<String, int> _gradeDistribution = {};

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Student Grade Manager'),
      centerTitle: true,
      elevation: 2,
      actions: [
        // Theme toggle with lambda
        IconButton(
          icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
          onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
          tooltip: 'Toggle theme',
        ),
        // Help button
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () => _showHelpDialog(),
          tooltip: 'Help',
        ),
      ],
    ),
    body: Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File selection section
          _buildFileSelectionSection(),
          const SizedBox(height: 20),
          
          // Status message
          if (_statusMessage != null) _buildStatusMessage(),
          if (_statusMessage != null) const SizedBox(height: 20),
          
          // Statistics section (shown when data is loaded)
          if (_students.isNotEmpty) _buildStatisticsSection(),
          if (_students.isNotEmpty) const SizedBox(height: 20),
          
          // Data table section
          Expanded(
            child: _buildDataTable(),
          ),
          
          // Export button section
          if (_students.isNotEmpty) _buildExportSection(),
        ],
      ),
    ),
  );

  // File selection section with lambda functions
  Widget _buildFileSelectionSection() => Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📁 Select Excel File',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Choose Excel File'),
                  onPressed: _isLoading ? null : () => _pickFile(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              if (_currentFilePath != null) ...[
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoading ? null : () => _reloadFile(),
                  tooltip: 'Reload file',
                ),
              ],
            ],
          ),
          if (_currentFilePath != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _currentFilePath!,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_isLoading) ...[
            const SizedBox(height: 15),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ],
      ),
    ),
  );

  // Status message widget
  Widget _buildStatusMessage() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _statusMessage!.contains('✅') 
          ? Colors.green.withOpacity(0.1)
          : _statusMessage!.contains('❌')
              ? Colors.red.withOpacity(0.1)
              : Colors.blue.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: _statusMessage!.contains('✅')
            ? Colors.green
            : _statusMessage!.contains('❌')
                ? Colors.red
                : Colors.blue,
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Icon(
          _statusMessage!.contains('✅') ? Icons.check_circle :
          _statusMessage!.contains('❌') ? Icons.error : Icons.info,
          color: _statusMessage!.contains('✅') ? Colors.green :
                 _statusMessage!.contains('❌') ? Colors.red : Colors.blue,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _statusMessage!,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
  );

  // Statistics section
  Widget _buildStatisticsSection() => Card(
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Statistics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Average Score',
                  '${_averageScore.toStringAsFixed(1)}%',
                  Icons.analytics,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  'Total Students',
                  _students.length.toString(),
                  Icons.people,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Grade Distribution:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['A', 'B', 'C', 'D', 'F'].map((grade) => 
              _buildGradeDistributionChip(
                grade,
                _gradeDistribution[grade] ?? 0,
              ),
            ).toList(),
          ),
        ],
      ),
    ),
  );

  // Stat card widget
  Widget _buildStatCard(String label, String value, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    ),
  );

  // Grade distribution chip
  Widget _buildGradeDistributionChip(String grade, int count) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: _getGradeColor(grade).withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _getGradeColor(grade)),
    ),
    child: Text(
      '$grade: $count',
      style: TextStyle(
        color: _getGradeColor(grade),
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // Data table widget
  Widget _buildDataTable() => Card(
    elevation: 4,
    child: _students.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.table_rows, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No data loaded',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  'Select an Excel file to begin',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      '📋 Student Records',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      '${_students.length} students',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: _students.length,
                  itemBuilder: (context, index) => _buildStudentTile(_students[index]),
                ),
              ),
            ],
          ),
  );

  // Student tile widget
  Widget _buildStudentTile(Map<String, dynamic> student) => Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
    ),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: _getGradeColor(student['grade']).withOpacity(0.2),
        child: Text(
          student['grade']?.substring(0, 1) ?? '?',
          style: TextStyle(
            color: _getGradeColor(student['grade']),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        student['name'] ?? 'Unknown',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text('Matricule: ${student['matricule'] ?? 'N/A'}'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: _getGradeColor(student['grade']).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${student['score']?.toStringAsFixed(1) ?? 'N/A'} → ${student['grade'] ?? '?'}',
          style: TextStyle(
            color: _getGradeColor(student['grade']),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );

  // Export section
  Widget _buildExportSection() => Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_alt),
              label: const Text('Export Graded File'),
              onPressed: () => _exportFile(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: () => _showPreviewDialog(),
            tooltip: 'Preview grades',
          ),
        ],
      ),
    ),
  );

  // Helper function to get grade color
  Color _getGradeColor(String? grade) {
    if (grade == null) return Colors.grey;
    switch (grade) {
      case 'A': return Colors.green;
      case 'B': return Colors.lightGreen;
      case 'C': return Colors.orange;
      case 'D': return Colors.deepOrange;
      case 'F': return Colors.red;
      default: return Colors.grey;
    }
  }

  // File picker function with lambda
  Future<void> _pickFile() async {
    setState(() => _isLoading = true);
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        String filePath = result.files.single.path!;
        setState(() => _currentFilePath = filePath);
        await _processExcelFile(filePath);
      } else {
        setState(() {
          _statusMessage = '❌ No file selected';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error picking file: $e';
        _isLoading = false;
      });
    }
  }

  // Process Excel file - contains your original logic with lambda adaptations
  Future<void> _processExcelFile(String filePath) async {
    setState(() => _isLoading = true);

    try {
      // Read Excel file (your original logic)
      final bytes = File(filePath).readAsBytesSync();
      final excelFile = excel.Excel.decodeBytes(bytes);  // Use prefix

      // Get first sheet
      final sheet = excelFile.tables.values.first;

      // Reset indices
      _nameColIndex = -1;
      _scoreColIndex = -1;
      _gradeColIndex = -1;

      // Find columns from header row
      final headerRow = sheet.rows.first;
      
      for (var i = 0; i < headerRow.length; i++) {
        final cell = headerRow[i];
        if (cell != null && cell.value != null) {
          final cellValue = cell.value.toString().toLowerCase().trim();
          
          // Using lambda-like conditions
          if (cellValue == "name") _nameColIndex = i;
          if (cellValue == "score") _scoreColIndex = i;
          if (cellValue == "grade") _gradeColIndex = i;
        }
      }

      // Verify required columns
      if (_nameColIndex == -1 || _scoreColIndex == -1) {
        setState(() {
          _statusMessage = '❌ Error: File must contain "Name" and "Score" columns';
          _isLoading = false;
          _students = [];
        });
        return;
      }

      // Process rows (skip header)
      List<Map<String, dynamic>> students = [];
      double totalScore = 0;
      Map<String, int> distribution = {'A': 0, 'B': 0, 'C': 0, 'D': 0, 'F': 0};
      int validScores = 0;

      for (var i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        
        if (row.isEmpty || row.length <= _nameColIndex) continue;

        // Get name
        final nameCell = row[_nameColIndex];
        if (nameCell == null || nameCell.value == null) continue;
        
        final name = nameCell.value.toString();

        // Get matricule (assuming it might be in the file)
        String matricule = '';
        if (row.length > 2 && row[2]?.value != null) {
          matricule = row[2]?.value?.toString() ?? '';
        }

        // Get score (your original logic with null safety)
        double? scoreValue;
        if (row.length > _scoreColIndex) {
          final scoreCell = row[_scoreColIndex];
          if (scoreCell != null) {
            var cellValue = scoreCell.value;
            if (cellValue != null) {
              String stringValue;
              if (cellValue is excel.TextCellValue) {  // Use prefix
                stringValue = cellValue.toString();
              } else if (cellValue is num) {
                stringValue = cellValue.toString();
              } else {
                stringValue = cellValue.toString();
              }
              stringValue = stringValue.trim();
              if (stringValue.isNotEmpty) {
                scoreValue = double.tryParse(stringValue);
              }
            }
          }
        }

        // Calculate grade
        String grade;
        if (scoreValue == null) {
          grade = "Invalid";
        } else {
          totalScore += scoreValue;
          validScores++;
          
          if (scoreValue >= 90.0) {
            grade = "A";
            distribution['A'] = (distribution['A'] ?? 0) + 1;
          } else if (scoreValue >= 80.0) {
            grade = "B";
            distribution['B'] = (distribution['B'] ?? 0) + 1;
          } else if (scoreValue >= 70.0) {
            grade = "C";
            distribution['C'] = (distribution['C'] ?? 0) + 1;
          } else if (scoreValue >= 60.0) {
            grade = "D";
            distribution['D'] = (distribution['D'] ?? 0) + 1;
          } else {
            grade = "F";
            distribution['F'] = (distribution['F'] ?? 0) + 1;
          }
        }

        students.add({
          'name': name,
          'matricule': matricule,
          'score': scoreValue,
          'grade': grade,
        });

        // Write grade to grade column if it exists
        if (_gradeColIndex != -1) {
          final newCell = sheet.cell(excel.CellIndex.indexByColumnRow(  // Use prefix
            columnIndex: _gradeColIndex,
            rowIndex: i
          ));
          newCell.value = excel.TextCellValue(grade);  // Use prefix
        }
      }

      // Calculate average
      double average = validScores > 0 ? totalScore / validScores : 0;

      setState(() {
        _students = students;
        _averageScore = average;
        _gradeDistribution = distribution;
        _statusMessage = '✅ Successfully loaded ${students.length} students';
        _isLoading = false;
      });

      // Save the graded file automatically
      String outputPath = filePath.replaceAll(".xlsx", "_graded.xlsx");
      final updatedBytes = excelFile.encode()!;
      File(outputPath).writeAsBytesSync(updatedBytes);

    } catch (e, stackTrace) {
      setState(() {
        _statusMessage = '❌ Error: ${e.toString().split('\n').first}';
        _isLoading = false;
        _students = [];
      });
      print(stackTrace);
    }
  }

  // Reload file
  Future<void> _reloadFile() async {
    if (_currentFilePath != null) {
      await _processExcelFile(_currentFilePath!);
    }
  }

  // Export file
  Future<void> _exportFile() async {
    try {
      if (_currentFilePath == null) return;

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Graded Excel File',
        fileName: 'graded_students.xlsx',
        allowedExtensions: ['xlsx'],
      );

      if (outputFile != null) {
        // Read the original file
        final bytes = File(_currentFilePath!).readAsBytesSync();
        final excelFile = excel.Excel.decodeBytes(bytes);  // Use prefix
        final sheet = excelFile.tables.values.first;

        // Update grades in the file
        for (var i = 0; i < _students.length; i++) {
          final student = _students[i];
          if (_gradeColIndex != -1 && i + 1 < sheet.rows.length) {
            final newCell = sheet.cell(excel.CellIndex.indexByColumnRow(  // Use prefix
              columnIndex: _gradeColIndex,
              rowIndex: i + 1
            ));
            newCell.value = excel.TextCellValue(student['grade'] ?? '');  // Use prefix
          }
        }

        // Save to new location
        final updatedBytes = excelFile.encode()!;
        File(outputFile).writeAsBytesSync(updatedBytes);

        setState(() {
          _statusMessage = '✅ File exported successfully to:\n$outputFile';
        });

        // Show success dialog
        _showExportSuccessDialog(outputFile);
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error exporting file: $e';
      });
    }
  }

  // Show preview dialog
  void _showPreviewDialog() => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Grade Preview'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _students.length,
          itemBuilder: (context, index) {
            final student = _students[index];
            return ListTile(
              leading: CircleAvatar(
                radius: 15,
                backgroundColor: _getGradeColor(student['grade']),
                child: Text(
                  student['grade'] ?? '?',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
              title: Text(student['name'] ?? ''),
              subtitle: Text('Score: ${student['score']?.toStringAsFixed(1) ?? 'N/A'}'),
              trailing: Text(
                student['grade'] ?? '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getGradeColor(student['grade']),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  // Show export success dialog
  void _showExportSuccessDialog(String filePath) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('✅ Export Successful'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your graded file has been saved to:'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              filePath,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );

  // Show help dialog
  void _showHelpDialog() => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('ℹ️ Help'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How to use this app:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('1. Click "Choose Excel File" to select your file'),
          Text('2. File must have "Name" and "Score" columns'),
          Text('3. App will automatically calculate grades:'),
          Text('   • A: 90-100'),
          Text('   • B: 80-89'),
          Text('   • C: 70-79'),
          Text('   • D: 60-69'),
          Text('   • F: Below 60'),
          Text('4. Click "Export" to save graded file'),
          SizedBox(height: 10),
          Text('The app also saves a "_graded" copy automatically!'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it!'),
        ),
      ],
    ),
  );
}