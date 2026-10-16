import 'package:flutter/material.dart';
import 'package:flutter_desktop_updater/flutter_desktop_updater.dart';
import 'package:forui/forui.dart';
import 'package:forui_27/authservice.dart';
import 'package:forui_27/login.dart';
import 'package:forui_27/updatescreen.dart';
import 'package:trina_grid/trina_grid.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Authservice authService = Authservice();

  List<dynamic> cacheDatas = [];
  List<TrinaRow> rows = [];

  TrinaGridStateManager? stateManager;

  bool isLoading = false;
  bool isSigningOut = false;
  String? errorMessage;

  late final List<TrinaColumn> columns = [
    TrinaColumn(
      title: 'Context',
      field: 'context',
      type: TrinaColumnType.text(),
      enableRowChecked: true,
      // readOnly: true,
    ),
    TrinaColumn(
      title: 'Shop ID',
      field: 'shop_id',
      type: TrinaColumnType.number(),
      // readOnly: true,
    ),
    TrinaColumn(
      title: 'User ID',
      field: 'user_id',
      type: TrinaColumnType.text(),
      // readOnly: true,
    ),
    TrinaColumn(
      title: 'Role',
      field: 'role',
      type: TrinaColumnType.select(<String>['Programmer', 'Designer', 'Owner']),
    ),
  ];

  void handleOnRowChecked(TrinaGridOnRowCheckedEvent event) {
    if (event.isRow) {
      // or event.isAll
      debugPrint('Toggled A Row.');
      debugPrint(event.row?.cells['context']?.value);
    } else {
      debugPrint('Toggled All Rows.');
      debugPrint(stateManager?.checkedRows.length.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    UpdateManager().checkForUpdate();
    getAllData();
  }

  List<TrinaRow> _buildRowsFromData(List<dynamic> data) {
    return data.map<TrinaRow>((item) {
      return TrinaRow(
        cells: {
          'context': TrinaCell(value: item['context']?.toString() ?? ''),
          'shop_id': TrinaCell(value: _parseShopId(item['shop_id'])),
          'user_id': TrinaCell(value: item['user_id']?.toString() ?? ''),
          'role': TrinaCell(value: item['role']?.toString() ?? 'Programmer'),
        },
      );
    }).toList();
  }

  Future<void> getAllData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final resp = await authService.getAllData();

      final loadedData = List<dynamic>.from(resp);
      rows = _buildRowsFromData(loadedData);

      if (!mounted) return;

      setState(() {
        cacheDatas = loadedData;
        isLoading = false;
      });

      // If the grid is already initialized, update it through
      // TrinaGridStateManager rather than modifying its rows directly.
      if (stateManager != null) {
        stateManager!.removeAllRows();
        stateManager!.appendRows(rows);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  num _parseShopId(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _logout() async {
    if (isSigningOut) return;

    setState(() {
      isSigningOut = true;
    });

    try {
      await authService.signOut();

      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute<void>(builder: (_) => const Login()));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Logout failed: $e')));

      setState(() {
        isSigningOut = false;
      });
    }
  }

  //fetch
  Future<TrinaLazyPaginationResponse> fetch(
    TrinaLazyPaginationRequest request,
  ) async {
    final page = request.page;
    const pageSize = 10;

    final totalRecords = await authService.getTotalDataCount();
    final requestedStart = (page - 1) * pageSize;
    final requestedEnd = (requestedStart + pageSize).clamp(0, totalRecords);

    if (rows.length < requestedEnd) {
      final fetchStart = rows.length;
      final fetchEnd = (fetchStart + pageSize - 1).clamp(0, totalRecords - 1);

      if (fetchStart < totalRecords) {
        final resp = await authService.getAllDataWithRange(
          fetchStart,
          fetchEnd,
        );
        final fetchRows = _buildRowsFromData(resp);
        rows.addAll(fetchRows);
        cacheDatas = [...cacheDatas, ...resp];
      }
    }

    final startIndex = requestedStart.clamp(0, rows.length);
    final endIndex = requestedEnd.clamp(0, rows.length);
    final showRows = rows.sublist(startIndex, endIndex);
    final totalPage = (totalRecords / pageSize).ceil();

    return TrinaLazyPaginationResponse(
      totalPage: totalPage,
      rows: showRows,
      totalRecords: totalRecords,
    );
  }
  //

  @override
  Widget build(BuildContext context) {
    final name = authService.getCurrentUserName();

    final currentStyle = Theme.brightnessOf(context) == Brightness.light
        ? TrinaGridStyleConfig(
            // gridBackgroundColor: Colors.white,
            // cellTextStyle: TextStyle(color: Colors.black),
          )
        : TrinaGridStyleConfig.dark(
            // gridBackgroundColor: Colors.white,
            // cellTextStyle: TextStyle(color: Colors.black),
          );

    return FScaffold(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Column(
                spacing: 16,
                children: [
                  // const UpdateBanner(),
                  FCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(name ?? 'Name not found'),
                    ),
                  ),
                  FButton(
                    onPress: () {
                      for (int i = 5; i < 11; i++) {
                        authService.addFakeData('Fake Data $i');
                      }
                      getAllData();
                    },
                    child: Text("Fake Data"),
                  ),
                  FButton(
                    onPress: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const Updatescreen()),
                      );
                    },
                    child: Text("ChechUpdate"),
                  ),
                  FButton(
                    onPress: _logout,
                    child: Text(isSigningOut ? 'Logging out...' : 'Logout'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text(
                        'User Data v2',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Refresh',
                        onPressed: isLoading ? null : getAllData,
                        icon: const Icon(Icons.refresh),
                      ),
                      IconButton(
                        tooltip: 'Print',
                        onPressed: () {
                          debugPrint('Print button pressed');
                        },
                        icon: const Icon(Icons.print),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Stack(
                      children: [
                        Material(
                          type: MaterialType.transparency,
                          color: Colors.white,
                          child: TrinaGrid(
                            key: const ValueKey('user-data-grid'),
                            configuration: TrinaGridConfiguration(
                              style: currentStyle,
                              columnSize: TrinaGridColumnSizeConfig(
                                autoSizeMode: TrinaAutoSizeMode.equal,
                              ),
                            ),
                            columns: columns,
                            rows: rows,
                            onLoaded: (TrinaGridOnLoadedEvent event) {
                              stateManager = event.stateManager;
                              stateManager?.setShowColumnFilter(true);
                              // Set the number of rows displayed per page.
                              event.stateManager.setPageSize(10, notify: true);

                              if (rows.isNotEmpty) {
                                event.stateManager.removeAllRows();
                                event.stateManager.appendRows(rows);
                              }
                            },
                            // mode: TrinaGridMode.readOnly,
                            onChanged: (event) {
                              // Handle cell edits here.
                              debugPrint('Grid value changed');
                            },
                            onRowChecked: handleOnRowChecked,
                            // createFooter: (stateManager) {
                            //   return TrinaPagination(
                            //     stateManager,
                            //     pageSizeToMove: 1,
                            //   );
                            // },
                            createFooter: (stateManager) {
                              return TrinaLazyPagination(
                                initialPage: 1,
                                initialFetch: true,
                                fetchWithSorting: true,
                                fetchWithFiltering: true,
                                pageSizeToMove: null,
                                fetch: fetch,
                                stateManager: stateManager,
                                // showTotalRows: showTotalRows,
                                // enableGotoPage: enableGotoPage,
                              );
                            },
                          ),
                        ),

                        if (isLoading)
                          const ColoredBox(
                            color: Color(0x66FFFFFF),
                            child: Center(child: CircularProgressIndicator()),
                          ),

                        if (!isLoading && errorMessage != null)
                          ColoredBox(
                            color: Colors.white,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Failed to load data:\n$errorMessage',
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: getAllData,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
