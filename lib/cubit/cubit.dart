import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/cubit/states.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks.dart';
import 'package:todo_app/modules/done_tasks/done_tasks.dart';
import 'package:todo_app/modules/new_tasks/new_tasks.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  // used for moving between bottomNavBar .
  int currentIndex = 0;

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  Database database;

  insertToDatabase({
    @required String title,
    @required String time,
    @required String date,
  }) async {
    await database.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO tasks (title, date, time, status) VALUES("$title","$date" , "$time", "new")')
          .then((value) {
        print('inserted successfully');
        emit(AppInsertDataBaseState());

        getDataFromDatabase(database);
      }).catchError((error) {
        print('error when inserting new record ${error.toString()}');
      });

      return null;
    });
  }

  void getDataFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(AppGetDataBaseLoadingState());
    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new')
          newTasks.add(element);
        else if (element['status'] == 'done')
          doneTasks.add(element);
        else
          archivedTasks.add(element);
      });
      emit(AppGetDataBaseState());
    });
  }

  void createDatabase() {
    openDatabase('todo.db ', version: 1, onCreate: (database, version) {
      database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT,date TEXT,time TEXT, status TEXT )')
          .then((value) {
        print('table created');
      }).catchError((error) {
        print('error when creating database${error.toString()}');
      });
    }, onOpen: (database) {
      print('database opened ');
      getDataFromDatabase(database);
    }).then((value) {
      database = value;
      emit(AppCreateDataBaseState());
    });
  }

  void updateData({@required String status, @required int id}) {
    database.rawUpdate('UPDATE tasks SET status = ? WHERE id = ? ',
        ['$status', id]).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDataBaseState());
    });
  }

  void deleteData({@required int id}) async {
    database.rawUpdate('DELETE FROM tasks WHERE id = ? ', [id]).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDataBaseState());
    });
  }

  bool isBottomSheetShown = false;

  IconData fabIcon = Icons.edit;

  void changeBottomSheetState(
      {@required bool isShow, @required IconData icon}) {
    isBottomSheetShown = isShow;

    fabIcon = icon;

    emit(AppChangeBottomSheetState());
  }
}
