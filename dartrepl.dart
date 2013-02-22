import 'dart:io';

const String prompt = '>> ';

void main() {
  final StringInputStream stream = new StringInputStream(stdin);
  final List<String> lines = new List<String>();
  final File tmpfile = new File('.dartrepl');
  final String dartvm = new Options().executable;

  stdout.writeString(prompt);
  stdout.flush();
  stream.onLine = () {
    var line = stream.readLine();
    if (line != null) {
      // TODO: Special commands for listing current program, editing lines, etc.

      // add line to list
      lines.add(line);

      // write lines to file
      var tmpstream = tmpfile.openOutputStream(FileMode.WRITE);
      lines.forEach((l) { tmpstream.writeString("$l\n"); });
      tmpstream.flush();

      // Spawn DART VM process with file as arg
      Process.start(dartvm, [tmpfile.fullPathSync()])
        ..then((p) => vm_running(p, lines))
        ..catchError((e) => vm_error(e));
    }
  };
}

void vm_running(Process p, List<String> lines) {
  var stdoutStream = new StringInputStream(p.stdout);
  stdoutStream.onLine =
      () => stdout.writeString("  << ${stdoutStream.readLine()}\n");
  p.onExit = (exitCode) {
    if (exitCode != 0) {
      stderr.writeString('[error] ');
      stderr.write(p.stderr.read());
    } else {
      stdout.writeString('[success]\n');
      lines.clear();
    }
    int i = 1;
    lines.forEach((l) { stdout.writeString(" $i. $l\n"); ++i; });
    p.kill(ProcessSignal.SIGQUIT);
    stdout.writeString(prompt);
    stdout.flush();
  };
}

bool vm_error(e) {
  stderr.writeString('Failed to start VM: ${e.message}\n');
  return true;
}
