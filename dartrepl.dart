#import('dart:core');
#import('dart:io');

void main() {
  final String prompt = '>> ';
  final StringInputStream stream = new StringInputStream(stdin);
  final List<String> lines = new List<String>();

  final File tmpfile = new File('.dartrepl');

  final String dartvm = (new Options()).arguments[0];

  print('$prompt');
  stream.onLine = () {
    var line = stream.readLine();
    if (line != null) {
      // add line to list
      lines.add(line);

      // write lines to file
      var tmpstream = tmpfile.openOutputStream(FileMode.WRITE);
      lines.forEach((l) {
        tmpstream.writeString(l);
      });
      tmpstream.flush();

      // Spawn DART VM process (from args?) with file as arg
      var p = Process.start(dartvm, [tmpfile.fullPathSync()]);
      var stdoutStream = new StringInputStream(p.stdout);
      stdoutStream.onLine = () => print("<< ${stdoutStream.readLine()}");
      p.onExit = (exitCode) {
        if (exitCode != 0) {
          print('Compile error');
        } else {
          print('Success');
        }
        p.close();
      };
    }
    print('$prompt');
  };
}
