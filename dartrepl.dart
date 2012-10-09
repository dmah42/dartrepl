#import('dart:core');
#import('dart:io');

void main() {
  const String prompt = '>> ';
  final StringInputStream stream = new StringInputStream(stdin);
  final List<String> lines = new List<String>();

  final File tmpfile = new File('.dartrepl');

  final String dartvm = (new Options()).arguments[0];

  stdout.writeString(prompt);
  stdout.flush();
  stream.onLine = () {
    var line = stream.readLine();
    if (line != null) {
      // TODO: Special commands for listing current program, inserting lines, etc.

      // add line to list
      lines.add(line);

      // write lines to file
      var tmpstream = tmpfile.openOutputStream(FileMode.WRITE);
      lines.forEach((l) { tmpstream.writeString(l); });
      tmpstream.flush();

      // Spawn DART VM process with file as arg
      var p = Process.start(dartvm, [tmpfile.fullPathSync()]);
      var stdoutStream = new StringInputStream(p.stdout);
      stdoutStream.onLine = () => stdout.writeString("  << ${stdoutStream.readLine()}\n");
      p.onExit = (exitCode) {
        if (exitCode != 0) {
          stdout.writeString('[error]\n');
          lines.forEach((l) { stdout.writeString("  $l\n"); });
        } else {
          stdout.writeString('[success]\n');
        }
        p.close();
        stdout.writeString(prompt);
        stdout.flush();
      };
    }
  };
}
