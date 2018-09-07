
abstract class TestCallAbstractClass{
  void call(String str, int number);
}

class TestCall extends TestCallAbstractClass{
  @override
  void call(String str, int number) {
    print('in TestCall: str = $str, number = $number');
  }
}

typedef TestCallback = void Function(String str, int number);

TestCallback testCallbackFunction = (String str, int number){
  print('in testCallbackFunction: str = $str, number = $number');
};

/// 上面两种方法定义基本一致。自我感觉还是Function， 这种方法更容易使用。