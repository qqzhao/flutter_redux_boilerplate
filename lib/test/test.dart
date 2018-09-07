

import 'package:flutter_redux_boilerplate/test/test_call_class.dart';

void testEntry(){
  TestCall testCall = new TestCall();
  testCall('test string', 2);
  testCallbackFunction('test string2', 33);
}