import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MainModel extends ChangeNotifier {
  static final MainModel _mainModel = MainModel._internal();
  factory MainModel() {
    return _mainModel;
  }

  MainModel._internal();

  static double _hours = 0;
  static double _rates = 0;

  double get hours => _hours;
  double get rates => _rates;

  set hours(double value) {
    if (value != _hours) {
      _hours = value;
      notifyListeners();
    }
  }

  set rates(double value) {
    if (value != _rates) {
      _rates = value;
      notifyListeners();
    }
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text("MAPD722 Pay Calculator"),
          ),
          body: Column(
            children: const [
              FormPanel(),
              OutputPanel(),
              AboutPanel(),
            ],
          ),
        ),
      ),
    );
  }
}

class FormPanel extends StatefulWidget {
  const FormPanel({Key? key}) : super(key: key);

  @override
  State<FormPanel> createState() => _FormPanelState();
}

class _FormPanelState extends State<FormPanel> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController hoursController = TextEditingController();
  TextEditingController ratesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainModel(),
      child: Consumer<MainModel>(builder: (context, model, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
          padding: const EdgeInsets.fromLTRB(50.0, 20.0, 50.0, 20.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blueAccent,
                width: 2,
              )),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: hoursController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    labelText: "Number of hours",
                    labelStyle: const TextStyle(fontSize: 16.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the hours worked';
                    } else if (double.parse(value) < 0) {
                      return 'Please enter a positive value';
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  controller: ratesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    labelText: "Hourly rates",
                    labelStyle: const TextStyle(fontSize: 16.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the hourly rate';
                    } else if (double.parse(value) < 0) {
                      return 'Please enter a positive value';
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  height: 50.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (_formKey.currentState?.validate() ?? false) {
                        model.hours = double.parse(hoursController.text);
                        model.rates = double.parse(ratesController.text);
                        print(
                            'form is valid to submit ${model.hours}, ${model.rates}');
                      }
                    },
                    child: const Text(
                      'Calculate',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class OutputPanel extends StatefulWidget {
  const OutputPanel({Key? key}) : super(key: key);

  @override
  State<OutputPanel> createState() => _OutputPanelState();
}

class _OutputPanelState extends State<OutputPanel> {
  static const String reportEmpty =
      'Regular pay \nOvertime pay \nTotal pay \nTax';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainModel(),
      child: Consumer<MainModel>(builder: (context, model, child) {
        return Expanded(
          child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
              padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 20.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blueAccent,
                    width: 2,
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Report',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    model.hours == 0 && model.rates == 0
                        ? reportEmpty
                        : getReportContent(model.hours, model.rates),
                    maxLines: 4,
                    style: const TextStyle(fontSize: 20.0),
                  ),
                ],
              )),
        );
      }),
    );
  }

  String getReportContent(double hr, double rts) {
    double overtimeHr = 0, regPay, overtimePay, totalPay, tax;
    if (hr > 40) {
      overtimeHr = hr - 40;
      hr = 40;
    }
    regPay = double.parse((hr * rts).toStringAsFixed(2));
    overtimePay = double.parse((overtimeHr * rts * 1.5).toStringAsFixed(2));
    totalPay = double.parse((regPay + overtimePay).toStringAsFixed(2));
    tax = double.parse((totalPay * 0.18).toStringAsFixed(2));
    return 'Regular pay \$$regPay\nOvertime pay \$$overtimePay\nTotal pay \$$totalPay\nTax \$$tax';
  }
}

class AboutPanel extends StatelessWidget {
  const AboutPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 30.0),
      decoration: BoxDecoration(
          color: Colors.lightBlue,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.blueAccent,
            width: 2,
          )),
      child: Column(
        children: const [
          Text(
            'Samuel Sum',
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
            '300858503',
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ],
      ),
    );
  }
}
