import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:todolists/controllers/task_controller.dart';
import 'package:todolists/models/task.dart';
import 'package:todolists/services/notification_services.dart';
import 'package:todolists/ui/theme.dart';
import 'package:todolists/ui/widgets/button.dart';
import 'package:todolists/ui/widgets/input_field.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  var notifyHelper;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    initializeDateFormatting('id');
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
  }

  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _startTime = DateFormat("hh:mm").format(DateTime.now()).toString();
  String _endTime = DateFormat("hh:mm")
      .format(DateTime.utc(2022, 7, 20, 20, 17, 04))
      .toString();
  int _selectedRemind = 5;
  List<int> remindList = [
    5,
    10,
    15,
    20,
  ];
  String _selectedRepeat = "Tidak";
  List<String> repeatList = ["Tidak", "Harian", "Mingguan", "Bulanan"];
  int _selectedColor = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: context.theme.backgroundColor,
        appBar: _appBar(context),
        body: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Buat Task",
                  style: headingStyle,
                ),
                MyInputField(
                    title: "Judul",
                    hint: "Masukkan Judul",
                    controller: _titleController),
                MyInputField(
                    title: "Catatan",
                    hint: "Masukkan Catatan",
                    controller: _noteController),
                MyInputField(
                    title: "Tanggal",
                    hint: DateFormat.yMd().format(_selectedDate),
                    widget: IconButton(
                        onPressed: () {
                          _getDateFromUser();
                        },
                        color: Colors.grey,
                        icon: Icon(Icons.calendar_today_outlined))),
                Row(
                  children: [
                    // Expanded(
                    //   child: MyInputField(
                    //       title: "Waktu Mulai",
                    //       // hint: "${_startTime.hour}:${_startTime.minute}",
                    //       hint: _startTime,
                    //       widget: IconButton(
                    //         onPressed: () {
                    //           _getTimeFromUserStart(isStartTime: true);
                    //         },
                    //         icon: Icon(Icons.access_time_rounded,
                    //             color: Colors.grey),
                    //       )),
                    // ),
                    // SizedBox(
                    //   width: 12,
                    // ),
                    Expanded(
                      child: MyInputField(
                          title: "Waktu Berakhir",
                          // hint: "${_endTime.hour}:${_endTime.minute}",
                          hint: _endTime,
                          widget: IconButton(
                            onPressed: () {
                              _getTimeFromUserEnd(isStartTime: false);
                            },
                            icon: Icon(Icons.access_time_rounded,
                                color: Colors.grey),
                          )),
                    ),
                  ],
                ),
                // MyInputField(
                //   title: "Ingatkan",
                //   hint: "$_selectedRemind menit lebih awal",
                //   widget: DropdownButton(
                //     icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                //     iconSize: 32,
                //     elevation: 4,
                //     style: subTitleStyle,
                //     underline: Container(
                //       height: 0,
                //     ),
                //     onChanged: (String? newValue) {
                //       setState(() {
                //         _selectedRemind = int.parse(newValue!);
                //       });
                //     },
                //     items: remindList.map<DropdownMenuItem<String>>(
                //       (int value) {
                //         return DropdownMenuItem<String>(
                //           value: value.toString(),
                //           child: Text(value.toString()),
                //         );
                //       },
                //     ).toList(),
                //   ),
                // ),
                // MyInputField(
                //   title: "Ulangi",
                //   hint: "$_selectedRepeat",
                //   widget: DropdownButton(
                //     icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                //     iconSize: 32,
                //     elevation: 4,
                //     style: subTitleStyle,
                //     underline: Container(
                //       height: 0,
                //     ),
                //     onChanged: (String? newValue) {
                //       setState(() {
                //         _selectedRepeat = newValue!;
                //       });
                //     },
                //     items: repeatList.map<DropdownMenuItem<String>>(
                //       (String? value) {
                //         return DropdownMenuItem<String>(
                //           value: value,
                //           child: Text(
                //             value!,
                //             style: TextStyle(color: Colors.grey),
                //           ),
                //         );
                //       },
                //     ).toList(),
                //   ),
                // ),
                Container(
                  margin: EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _colorPallete(),
                      MyButton(
                          label: "Buat Task",
                          onTap: () {
                            _validateDate();
                          })
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  _validateDate() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _addTaskToDb();
      Get.back();
    } else if (_titleController.text.isEmpty || _noteController.text.isEmpty) {
      Get.snackbar(
        "Wajib",
        "Semua kolom wajib diisi!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode ? Colors.white : Colors.black,
        colorText: pinkClr,
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Colors.red,
        ),
      );
    }
  }

  _addTaskToDb() async {
    int value = await _taskController.addTask(
        task: Task(
      note: _noteController.text,
      title: _titleController.text,
      date: DateFormat.yMd().format(_selectedDate),
      startTime: _startTime,
      endTime: _endTime,
      remind: _selectedRemind,
      repeat: _selectedRepeat,
      color: _selectedColor,
      isCompleted: 0,
    ));
    print("Id is " + "$value");
  }

  _colorPallete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Warna Task",
          style: titleStyle,
        ),
        SizedBox(height: 8.0),
        Wrap(
          children: List<Widget>.generate(3, (int index) {
            return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = index;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: index == 0
                        ? primaryClr
                        : index == 1
                            ? pinkClr
                            : yellowClr,
                    child: _selectedColor == index
                        ? Icon(Icons.done, color: Colors.white, size: 16)
                        : Container(),
                  ),
                ));
          }),
        )
      ],
    );
  }

  _appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Icon(Icons.arrow_back_ios,
            size: 20, color: Get.isDarkMode ? Colors.white : Colors.black),
      ),
      actions: [
        CircleAvatar(
          backgroundImage: AssetImage("images/profile.png"),
        ),
        SizedBox(width: 20),
      ],
    );
  }

  _getDateFromUser() async {
    DateTime? _pickerDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015),
        lastDate: DateTime(2222));

    if (_pickerDate != null) {
      setState(() {
        _selectedDate = _pickerDate;
      });
    } else {
      print("its null something wrong");
    }
  }

  _getTimeFromUserStart({required bool isStartTime}) async {
    // final String? timeOfDay = await showTimePicker(
    //     context: context,
    //     initialTime: TimeOfDay(
    //         hour: int.parse(_startTime.split(":")[0]),
    //         minute: int.parse(_startTime.split(":")[1])),
    //     initialEntryMode: TimePickerEntryMode.input);
    var pickedTime = await _showTimePicker();
    String _formatedTime = pickedTime.format(context);
    if (_formatedTime == null) {
      print("Time Cancel");
    } else if (isStartTime == true) {
      setState(() {
        _startTime = _formatedTime;
      });
    } else if (isStartTime == false) {
      print("error");
    }
  }

  _getTimeFromUserEnd({required bool isStartTime}) async {
    var pickedTime = await _showTimePickerEnd();
    String _formatedTime = pickedTime.format(context);

    if (_formatedTime == null) {
      print("Time Cancel");
    } else if (isStartTime == true) {
      print("error");
    } else if (isStartTime == false) {
      setState(() {
        _endTime = _formatedTime;
      });
    }
  }

  _showTimePickerEnd() {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: int.parse(_endTime.split(":")[0]),
          minute: int.parse(_endTime.split(":")[1])),
      initialEntryMode: TimePickerEntryMode.input,
    );
  }

  _showTimePicker() {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: int.parse(_startTime.split(":")[0]),
          minute: int.parse(_startTime.split(":")[1])),
      initialEntryMode: TimePickerEntryMode.input,
    );
  }
}
