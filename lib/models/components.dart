import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/cubit/cubit.dart';

Widget defaultFormField({
  @required TextEditingController controller,
  @required TextInputType type,
  Function onSubmit,
  Function onChange,
  Function onTap,
  bool isPassword = false,
  @required Function validate,
  @required String label,
  @required IconData prefix,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: type,
    obscureText: isPassword,
    onFieldSubmitted: onSubmit,
    onChanged: onChange,
    onTap: onTap,
    validator: validate,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(prefix),
      border: OutlineInputBorder(),
    ),
  );
}

var direction = DismissDirection.endToStart;
Widget buildTaskItem(Map model, context) => Dismissible(
      direction: direction,
      key: Key(model['id'].toString()),
      background: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
              size: 30,
            )
          ],
        ),
        color: Colors.red,
      ),
      onDismissed: (direction) {
        AppCubit.get(context).deleteData(id: model['id']);
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              child: Text("${model['time']}"),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${model['title']}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${model['date']}",
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
            SizedBox(width: 20),
            IconButton(
              color: Colors.green,
              onPressed: () {
                AppCubit.get(context)
                    .updateData(status: 'done', id: model['id']);
              },
              icon: Icon(Icons.check_box),
            ),
            IconButton(
              color: Colors.grey,
              onPressed: () {
                AppCubit.get(context)
                    .updateData(status: 'archive', id: model['id']);
              },
              icon: Icon(Icons.archive),
            )
          ],
        ),
      ),
    );

Widget tasksConditionBuilder({@required List<Map> tasks}) => ConditionalBuilder(
      condition: tasks.length > 0,
      builder: (context) => ListView.separated(
          itemBuilder: (context, index) => buildTaskItem(tasks[index], context),
          separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsetsDirectional.only(start: 20.0),
                child: Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey[300],
                ),
              ),
          itemCount: tasks.length),
      fallback: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu,
              size: 100,
              color: Colors.grey,
            ),
            Text(
              'No tasks added yet , please add some tasks',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )
          ],
        ),
      ),
    );
