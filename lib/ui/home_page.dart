import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:todolists/controllers/task_controller.dart';
import 'package:todolists/models/task.dart';
import 'package:todolists/services/notification_services.dart';
import 'package:todolists/services/theme_services.dart';
import 'package:todolists/ui/add_task_bar.dart';
import 'package:todolists/ui/theme.dart';
import 'package:todolists/ui/widgets/button.dart';
import 'package:todolists/ui/widgets/task_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _taskController = Get.put(TaskController());
  DateTime _selectedDate = DateTime.now();
  int alarmId = 1;
  var notifyHelper;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    initializeDateFormatting('id');
    // AndroidAlarmManager.initialize();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: context.theme.backgroundColor,
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          SizedBox(
            height: 10,
          ),
          _showTasks(),
        ],
      ),
    );
  }

  _showTasks() {
    return Expanded(
      child: Obx(() {
        return ListView.builder(
            itemCount: _taskController.taskList.length,
            itemBuilder: (_, index) {
              Task task = _taskController.taskList[index];
              print(task.toJson());
              // if (task.repeat == "Harian") {


              //   // print(remind);

              //   return AnimationConfiguration.staggeredList(
              //       position: index,
              //       child: SlideAnimation(
              //         child: FadeInAnimation(
              //           child: Row(
              //             children: [
              //               GestureDetector(
              //                 onTap: () {
              //                   _showBottomSheet(context, task);
              //                 },
              //                 child: TaskTile(task),
              //               )
              //             ],
              //           ),
              //         ),
              //       ));
              // }
              if (task.date == DateFormat.yMd().format(_selectedDate)) {
                DateTime date =
                    DateFormat("HH:mm").parse(task.endTime.toString());
                var myTime = DateFormat("HH:mm").format(date);
                final month = int.parse(task.date.toString().split("/")[0]);
                  final day = int.parse(task.date.toString().split("/")[1]);
                  final year = int.parse(task.date.toString().split("/")[2]);
                  final endTime1 =
                      int.parse(task.endTime.toString().split(":")[0]);
                  final endTime2 =
                      int.parse(task.endTime.toString().split(":")[1]);

                  final birthday =
                      DateTime(year, month, day, endTime1, endTime2);
                  final date2 = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      DateTime.now().hour,
                      DateTime.now().minute,
                      DateTime.now().second);
                  final difference = birthday.difference(date2).inSeconds;
                  print(difference);
                  print(date2);
                  final sebelumJamSekarang = date2.isBefore(birthday);
                  print(sebelumJamSekarang);

                  // final ingatkan =
                  //     difference - int.parse(task.remind.toString());
                  // print(ingatkan);
                  if (sebelumJamSekarang == true) {
                    // /* Ingatkan */
                    // notifyHelper.scheduledNotificationTask(
                    //     int.parse(myTime.toString().split(":")[0]),
                    //     int.parse(myTime.toString().split(":")[1]),
                    //     task,
                    //     int.parse(ingatkan.toString()));
                    /* Notif melewati ingatkan */
                    notifyHelper.scheduledNotification(
                        int.parse(myTime.toString().split(":")[0]),
                        int.parse(myTime.toString().split(":")[1]),
                        task,
                        difference);
                  } else {
                    notifyHelper.displayNotificationTask(
                        title: task.title, body: task.note);
                  }

                return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showBottomSheet(context, task);
                              },
                              child: TaskTile(task),
                            )
                          ],
                        ),
                      ),
                    ));
              } else {
                return Container();
              }
            });
      }),
    );
  }

  _bottomSheetButton(
      {required String label,
      required Function()? onTap,
      required Color clr,
      bool isClose = false,
      required BuildContext context}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        height: 55,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isClose == true
                ? Get.isDarkMode
                    ? Colors.grey[600]!
                    : Colors.grey[300]!
                : clr,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClose == true ? Colors.transparent : clr,
        ),
        child: Center(
          child: Text(
            label,
            style: isClose == true
                ? titleStyle
                : titleStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(Container(
      padding: EdgeInsets.only(top: 4),
      height: task.isCompleted == 1
          ? MediaQuery.of(context).size.height * 0.24
          : MediaQuery.of(context).size.height * 0.32,
      color: Get.isDarkMode ? darkGreyClr : Colors.white,
      child: Column(
        children: [
          Container(
            height: 6,
            width: 120,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]),
          ),
          Spacer(),
          task.isCompleted == 1
              ? Container()
              : _bottomSheetButton(
                  label: "Task Selesai",
                  onTap: () {
                    _taskController.markTaskCompleted(task.id!);
                    Get.back();
                  },
                  clr: primaryClr,
                  context: context),
          _bottomSheetButton(
              label: "Hapus Task",
              onTap: () {
                _taskController.delete(task);
                Get.back();
              },
              clr: Colors.red[300]!,
              context: context),
          SizedBox(
            height: 20,
          ),
          _bottomSheetButton(
              label: "Tutup",
              onTap: () {
                Get.back();
              },
              clr: Colors.red[300]!,
              isClose: true,
              context: context),
          SizedBox(
            height: 10,
          )
        ],
      ),
    ));
  }

  _addDateBar() {
    return Container(
        margin: EdgeInsets.only(top: 20, left: 20),
        // decoration: BoxDecoration(
        //   border: Border.all(
        //     width: 1,
        //     color: primaryClr
        //   ),
        //   borderRadius: BorderRadius.circular(10)
        // ),
        child: DatePicker(
          DateTime.now(),
          height: 100,
          width: 50,
          initialSelectedDate: DateTime.now(),
          selectionColor: primaryClr,
          selectedTextColor: Colors.white,
          dateTextStyle: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
          dayTextStyle: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
          monthTextStyle: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
          onDateChange: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
          locale: "id",
        ));
  }

  _addTaskBar() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat.yMMMMd('id').format(DateTime.now()),
                    style: subHeadingStyle),
                Text(
                  'Hari Ini',
                  style: headingStyle,
                )
              ],
            ),
          ),
          MyButton(
              label: "+ Buat Task",
              onTap: () async {
                await Get.to(() => AddTaskPage());
                _taskController.getTasks();
              })
        ],
      ),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          ThemeService().switchTheme();
        },
        child: Icon(
            Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
            size: 20,
            color: Get.isDarkMode ? Colors.white : Colors.black),
      ),
      // actions: [
      //   CircleAvatar(
      //     backgroundImage: AssetImage("images/profile.png"),
      //   ),
      //   SizedBox(width: 20),
      // ],
    );
  }
}
