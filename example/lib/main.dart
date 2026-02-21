import 'package:flutter/material.dart';
import 'package:better_data_table/better_data_table.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BetterDataTable Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExamplesPage(),
    );
  }
}

class ExamplesPage extends StatelessWidget {
  const ExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BetterDataTable Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('1. Basic Table'),
          const BasicTableExample(),
          const SizedBox(height: 32),
          _buildSectionTitle('2. Sortable Table'),
          const SortableTableExample(),
          const SizedBox(height: 32),
          _buildSectionTitle('3. Table with Selection'),
          const SelectableTableExample(),
          const SizedBox(height: 32),
          _buildSectionTitle('4. Hierarchical/Nested Rows'),
          const ExpandableTableExample(),
          const SizedBox(height: 32),
          _buildSectionTitle('5. Table with Footer'),
          const FooterTableExample(),
          const SizedBox(height: 32),
          _buildSectionTitle('6. Custom Icons'),
          const CustomIconsExample(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Example 1: Basic Table
class BasicTableExample extends StatelessWidget {
  const BasicTableExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BetterDataTable(
          columns: [
            BetterDataTableColumn(
              header: const Text('Name'),
              width: const FlexColumnWidth(2),
            ),
            BetterDataTableColumn(
              header: const Text('Age'),
              width: const FixedColumnWidth(80),
            ),
            BetterDataTableColumn(
              header: const Text('City'),
              width: const FlexColumnWidth(1),
            ),
          ],
          rows: [
            BetterDataTableRow(
              cells: [
                const Text('Alice Johnson'),
                const Text('28'),
                const Text('New York'),
              ],
            ),
            BetterDataTableRow(
              cells: [
                const Text('Bob Smith'),
                const Text('34'),
                const Text('Los Angeles'),
              ],
            ),
            BetterDataTableRow(
              cells: [
                const Text('Carol White'),
                const Text('25'),
                const Text('Chicago'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Example 2: Sortable Table
class SortableTableExample extends StatefulWidget {
  const SortableTableExample({super.key});

  @override
  State<SortableTableExample> createState() => _SortableTableExampleState();
}

class _SortableTableExampleState extends State<SortableTableExample> {
  int? sortColumnIndex;
  bool sortAscending = true;
  List<Person> people = [
    Person('Alice Johnson', 28, 'New York'),
    Person('Bob Smith', 34, 'Los Angeles'),
    Person('Carol White', 25, 'Chicago'),
    Person('David Brown', 42, 'Houston'),
  ];

  void _sort(int columnIndex) {
    setState(() {
      if (sortColumnIndex == columnIndex) {
        sortAscending = !sortAscending;
      } else {
        sortColumnIndex = columnIndex;
        sortAscending = true;
      }

      switch (columnIndex) {
        case 0:
          people.sort(
            (a, b) => sortAscending
                ? a.name.compareTo(b.name)
                : b.name.compareTo(a.name),
          );
          break;
        case 1:
          people.sort(
            (a, b) =>
                sortAscending ? a.age.compareTo(b.age) : b.age.compareTo(a.age),
          );
          break;
        case 2:
          people.sort(
            (a, b) => sortAscending
                ? a.city.compareTo(b.city)
                : b.city.compareTo(a.city),
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BetterDataTable(
          theme: BetterDataTableTheme.defaultTheme(context),
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortAscending,
          onSort: _sort,
          columns: [
            BetterDataTableColumn(
              header: const Text('Name'),
              sortable: true,
              width: const FlexColumnWidth(2),
            ),
            BetterDataTableColumn(
              header: const Text('Age'),
              sortable: true,
              width: const FixedColumnWidth(80),
            ),
            BetterDataTableColumn(
              header: const Text('City'),
              sortable: true,
              width: const FlexColumnWidth(1),
            ),
          ],
          rows: people
              .map(
                (person) => BetterDataTableRow(
                  cells: [
                    Text(person.name),
                    Text('${person.age}'),
                    Text(person.city),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// Example 3: Selectable Table
class SelectableTableExample extends StatefulWidget {
  const SelectableTableExample({super.key});

  @override
  State<SelectableTableExample> createState() => _SelectableTableExampleState();
}

class _SelectableTableExampleState extends State<SelectableTableExample> {
  Set<int> selectedRows = {};

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Selected: ${selectedRows.length} rows',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            BetterDataTable(
              showCheckboxes: true,
              selectedRows: selectedRows,
              onRowSelected: (index) {
                setState(() {
                  if (selectedRows.contains(index)) {
                    selectedRows.remove(index);
                  } else {
                    selectedRows.add(index);
                  }
                });
              },
              onSelectAll: (selected) {
                setState(() {
                  if (selected == true) {
                    selectedRows = Set.from(List.generate(5, (i) => i));
                  } else {
                    selectedRows.clear();
                  }
                });
              },
              columns: [
                BetterDataTableColumn(header: const Text('Item')),
                BetterDataTableColumn(header: const Text('Status')),
              ],
              rows: List.generate(
                5,
                (i) => BetterDataTableRow(
                  cells: [Text('Item ${i + 1}'), Text('Active')],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example 4: Hierarchical/Nested Rows (like ClickUp tasks)
class ExpandableTableExample extends StatefulWidget {
  const ExpandableTableExample({super.key});

  @override
  State<ExpandableTableExample> createState() => _ExpandableTableExampleState();
}

class _ExpandableTableExampleState extends State<ExpandableTableExample> {
  Set<String> expandedRows = {'0', '0.0', '1'};

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nested tasks with infinite levels (like ClickUp)',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            BetterDataTable(
              expandedRows: expandedRows,
              onRowExpanded: (path) {
                setState(() {
                  if (expandedRows.contains(path)) {
                    expandedRows.remove(path);
                  } else {
                    expandedRows.add(path);
                  }
                });
              },
              columns: [
                BetterDataTableColumn(
                  header: const Text('Task'),
                  width: const FlexColumnWidth(3),
                ),
                BetterDataTableColumn(
                  header: const Text('Status'),
                  width: const FlexColumnWidth(1),
                ),
                BetterDataTableColumn(
                  header: const Text('Priority'),
                  width: const FixedColumnWidth(100),
                ),
              ],
              rows: [
                // Project 1 with nested tasks
                BetterDataTableRow(
                  cells: [
                    const Text('Project Alpha'),
                    const Text('In Progress'),
                    const Text('High'),
                  ],
                  children: [
                    // Phase 1
                    BetterDataTableRow(
                      cells: [
                        const Text('Phase 1: Planning'),
                        const Text('Completed'),
                        const Text('High'),
                      ],
                      children: [
                        BetterDataTableRow(
                          cells: [
                            const Text('Research market needs'),
                            const Text('Done'),
                            const Text('Medium'),
                          ],
                        ),
                        BetterDataTableRow(
                          cells: [
                            const Text('Define requirements'),
                            const Text('Done'),
                            const Text('High'),
                          ],
                          children: [
                            BetterDataTableRow(
                              cells: [
                                const Text('Gather stakeholder input'),
                                const Text('Done'),
                                const Text('Medium'),
                              ],
                            ),
                            BetterDataTableRow(
                              cells: [
                                const Text('Write specifications'),
                                const Text('Done'),
                                const Text('High'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Phase 2
                    BetterDataTableRow(
                      cells: [
                        const Text('Phase 2: Development'),
                        const Text('In Progress'),
                        const Text('High'),
                      ],
                      children: [
                        BetterDataTableRow(
                          cells: [
                            const Text('Backend API'),
                            const Text('In Progress'),
                            const Text('High'),
                          ],
                        ),
                        BetterDataTableRow(
                          cells: [
                            const Text('Frontend UI'),
                            const Text('Not Started'),
                            const Text('Medium'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                // Project 2
                BetterDataTableRow(
                  cells: [
                    const Text('Project Beta'),
                    const Text('Planning'),
                    const Text('Medium'),
                  ],
                  children: [
                    BetterDataTableRow(
                      cells: [
                        const Text('Initial research'),
                        const Text('In Progress'),
                        const Text('Medium'),
                      ],
                    ),
                  ],
                ),
                // Simple task without children
                BetterDataTableRow(
                  cells: [
                    const Text('Standalone Task'),
                    const Text('Completed'),
                    const Text('Low'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Example 5: Table with Footer
class FooterTableExample extends StatelessWidget {
  const FooterTableExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BetterDataTable(
          columns: [
            BetterDataTableColumn(
              header: const Text('Item'),
              width: const FlexColumnWidth(2),
            ),
            BetterDataTableColumn(
              header: const Text('Quantity'),
              width: const FixedColumnWidth(100),
              cellAlignment: Alignment.centerRight,
            ),
            BetterDataTableColumn(
              header: const Text('Price'),
              width: const FixedColumnWidth(100),
              cellAlignment: Alignment.centerRight,
            ),
          ],
          rows: [
            BetterDataTableRow(
              cells: [
                const Text('Apple'),
                const Text('5', textAlign: TextAlign.right),
                const Text('\$10.00', textAlign: TextAlign.right),
              ],
            ),
            BetterDataTableRow(
              cells: [
                const Text('Banana'),
                const Text('3', textAlign: TextAlign.right),
                const Text('\$6.00', textAlign: TextAlign.right),
              ],
            ),
            BetterDataTableRow(
              cells: [
                const Text('Orange'),
                const Text('2', textAlign: TextAlign.right),
                const Text('\$8.00', textAlign: TextAlign.right),
              ],
            ),
          ],
          footerRows: [
            BetterDataTableRow(
              cells: [
                const Text('Total'),
                const Text('10', textAlign: TextAlign.right),
                const Text('\$24.00', textAlign: TextAlign.right),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Example 6: Custom Icons
class CustomIconsExample extends StatefulWidget {
  const CustomIconsExample({super.key});

  @override
  State<CustomIconsExample> createState() => _CustomIconsExampleState();
}

class _CustomIconsExampleState extends State<CustomIconsExample> {
  int? sortColumnIndex;
  bool sortAscending = true;
  Set<String> expandedRows = {};

  void _sort(int index) {
    setState(() {
      if (sortColumnIndex == index) {
        sortAscending = !sortAscending;
      } else {
        sortColumnIndex = index;
        sortAscending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort arrows replaced with triangles, expand toggles replaced with +/− circles.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            BetterDataTable(
              theme: BetterDataTableTheme.defaultTheme(context).copyWith(
                sortAscendingIcon: const Icon(
                  Icons.arrow_drop_up,
                  size: 20,
                  color: Colors.deepPurple,
                ),
                sortDescendingIcon: const Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: Colors.deepPurple,
                ),
                rowExpandIcon: const Icon(
                  Icons.add_circle_outline,
                  size: 18,
                ),
                rowCollapseIcon: const Icon(
                  Icons.remove_circle_outline,
                  size: 18,
                ),
              ),
              sortColumnIndex: sortColumnIndex,
              sortAscending: sortAscending,
              onSort: _sort,
              expandedRows: expandedRows,
              onRowExpanded: (path) {
                setState(() {
                  expandedRows.contains(path)
                      ? expandedRows.remove(path)
                      : expandedRows.add(path);
                });
              },
              onRowTap: (index) {},
              columns: [
                BetterDataTableColumn(
                  header: const Text('Task'),
                  sortable: true,
                  width: const FlexColumnWidth(3),
                ),
                BetterDataTableColumn(
                  header: const Text('Status'),
                  sortable: true,
                  width: const FlexColumnWidth(1),
                ),
              ],
              rows: [
                BetterDataTableRow(
                  cells: const [Text('Project Alpha'), Text('Active')],
                  children: [
                    BetterDataTableRow(
                      cells: const [Text('Phase 1'), Text('Done')],
                    ),
                    BetterDataTableRow(
                      cells: const [Text('Phase 2'), Text('In Progress')],
                    ),
                  ],
                ),
                BetterDataTableRow(
                  cells: const [Text('Project Beta'), Text('Planning')],
                  children: [
                    BetterDataTableRow(
                      cells: const [Text('Research'), Text('Pending')],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class for sortable example
class Person {
  final String name;
  final int age;
  final String city;

  Person(this.name, this.age, this.city);
}
