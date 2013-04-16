#!/usr/bin/env python3
# -*- coding: utf-8 -*-
'''
celestia – Automated package distribution updater

Copyright © 2013  Mattias Andrée (maandree@member.fsf.org)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''
import os
from submodule import Popen, PIPE


def update(directory):
    try:
        os.chdir(directory)
        output = Popen(['./version'], stdout = PIPE, cwd = directory).communicate()[0]
        output = output.split(' ')
        if len(output) == 2:
            (name, version) = output
            filename = '%s/%s' % ('${SPOOL}', name)
            data = None
            with open('template', 'rb') as file:
                file.read().decode('utf-8', 'replace')
            bufstack = ['']
            for c in data:
                if c == '{':
                    bufstack.append('{')
                else if c == '}':
                    bufstack[-1] += c
                    if (len(bufstack) > 1) and (bufstack[-2].endswith('€')):
                        bufstack[-2] = bufstack[-2][:-1]
                        appendix = bufstack[-1][1 : -1]
                        if   appendix == '<':  appendix = '{'
                        elif appendix == '>':  appendix = '}'
                        elif appendix == '':   appendix = '€'
                        elif appendix == 'name':      appendix = name
                        elif appendix == 'version':   appendix = version
                        elif appendix == 'filename':  appendix = filename
                        else:
                            appendix = ['bash', '-c', appendix]
                            appendix = Popen(appendix, stdout = PIPE, cwd = directory).communicate()[0]
                        bufstack[-2] += appendix.replace('€', '€\0')
                    else:
                        bufstack[-2] += bufstack[-1]
                    bufstack.pop()
                else:
                    bufstack[-1] += c
            buf = ''
            for elem in bufstack:
                buf += elem
            with open(filename, 'wb') as file:
                file.write(buf.replace('\0', '').encode('utf-8'))
            if os.path.exists('./finalise'):
                Popen(['./finalise', name, version, filename, '${SPOOL}'], cwd = directory).wait()
            print('%s %s %s' % (name, version, filename))
    except:
        pass


if __name__ == '__main__':
    if os.path.exists('${LIST}'):
        list = None
        with open('${LIST}', 'rb') as file:
            list = file.read()
        list = list.decode('utf-8', 'replace')
        for item in list.split('\n'):
            if (len(item) > 0) and (item[0] != '#'):
                update(item + '/')


