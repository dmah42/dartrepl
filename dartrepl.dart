import 'dart:async';
import 'dart:convert';
import 'dart:io';

const String in_prompt = '>> ';
const String out_prefix = '<< ';

void main() {
  final List<String> lines = new List<String>();
  final File tmpfile = new File('.dartrepl');
  final String dartvm = Platform.executable;

  stdout.write(in_prompt);
  //stdout.flush();
  stdin
    .transform(UTF8.decoder)
    .transform(new LineSplitter())
    .listen((String line) {
        // TODO: Special commands for listing current program, editing lines, etc.

        // add line to list
        lines.add(line);

        // write lines to file
        var tmpstream = tmpfile.openWrite();
        lines.forEach((l) { tmpstream.writeln("$l"); });
        //tmpstream.flush();

        // Spawn DART VM process with file as arg
        Process.start(dartvm, [tmpfile.path])
          ..then((p) => vm_running(p, lines))
          ..catchError((e) => vm_error(e));
    });
}

void vm_running(Process p, List<String> lines) {
  p.stdout
    .transform(UTF8.decoder)
    .transform(new LineSplitter())
    .listen((String line) {
        stdout.writeln("  $out_prefix $line");
    });
  p.exitCode.then((exitCode) {
      if (exitCode != 0) {
        stderr.write('[error] ');
        stderr.addStream(p.stderr);
      } else {
        stdout.writeln('[success]');
        lines.clear();
      }
      int i = 1;
      lines.forEach((l) { stdout.writeln(" $i. $l"); ++i; });
      p.kill(ProcessSignal.SIGQUIT);
      stdout.write(in_prompt);
      //stdout.flush();
  });
}

bool vm_error(e) {
  stderr.writeln('Failed to start VM: ${e.message}');
  return true;
}
