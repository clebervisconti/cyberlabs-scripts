#!/usr/bin/env python3
import sys
import re
from html.parser import HTMLParser

class HTMLToMarkdown(HTMLParser):
    def __init__(self):
        super().__init__()
        self.result = []
        self.stack = []
        
        # State tracking
        self.in_pre = False
        self.in_code = False
        self.current_link = None
        self.list_index_stack = []  # None for ul, int for ol
        
        # Table tracking
        self.in_table = False
        self.table_data = []
        self.current_row = []
        self.in_cell = False
        self.cell_content = []

    def handle_starttag(self, tag, attrs):
        attrs_dict = dict(attrs)
        self.stack.append(tag)

        # If parsing cells inside a table, we collect text in cell_content
        if self.in_table:
            if tag in ('th', 'td'):
                self.in_cell = True
                self.cell_content = []
            elif tag == 'tr':
                self.current_row = []
            return

        if tag in ('p', 'div'):
            self.result.append('\n\n')
        elif tag == 'br':
            self.result.append('\n')
        elif tag == 'hr':
            self.result.append('\n\n---\n\n')
        elif tag in ('h1', 'h2', 'h3', 'h4', 'h5', 'h6'):
            level = int(tag[1])
            self.result.append('\n\n' + '#' * level + ' ')
        elif tag in ('strong', 'b'):
            self.result.append('**')
        elif tag in ('em', 'i'):
            self.result.append('*')
        elif tag in ('del', 's'):
            self.result.append('~~')
        elif tag == 'code':
            self.in_code = True
            if not self.in_pre:
                self.result.append('`')
        elif tag == 'pre':
            self.in_pre = True
            self.result.append('\n\n```\n')
        elif tag == 'a':
            self.current_link = attrs_dict.get('href')
            self.result.append('[')
        elif tag == 'blockquote':
            self.result.append('\n\n> ')
        elif tag == 'ul':
            self.list_index_stack.append(None)
            self.result.append('\n')
        elif tag == 'ol':
            self.list_index_stack.append(1)
            self.result.append('\n')
        elif tag == 'li':
            indent = '  ' * (len(self.list_index_stack) - 1)
            if self.list_index_stack and self.list_index_stack[-1] is not None:
                index = self.list_index_stack[-1]
                self.result.append(f'\n{indent}{index}. ')
                self.list_index_stack[-1] += 1
            else:
                self.result.append(f'\n{indent}- ')
        elif tag == 'img':
            src = attrs_dict.get('src', '')
            alt = attrs_dict.get('alt', '') or attrs_dict.get('title', '') or 'image'
            self.result.append(f'![{alt}]({src})')
        elif tag == 'table':
            self.in_table = True
            self.table_data = []

    def handle_endtag(self, tag):
        if self.stack and self.stack[-1] == tag:
            self.stack.pop()

        if self.in_table:
            if tag in ('th', 'td'):
                self.in_cell = False
                self.current_row.append(''.join(self.cell_content).strip())
            elif tag == 'tr':
                self.table_data.append(self.current_row)
            elif tag == 'table':
                self.in_table = False
                self.render_table()
            return

        if tag in ('p', 'div'):
            self.result.append('\n\n')
        elif tag in ('h1', 'h2', 'h3', 'h4', 'h5', 'h6'):
            self.result.append('\n\n')
        elif tag in ('strong', 'b'):
            self.result.append('**')
        elif tag in ('em', 'i'):
            self.result.append('*')
        elif tag in ('del', 's'):
            self.result.append('~~')
        elif tag == 'code':
            self.in_code = False
            if not self.in_pre:
                self.result.append('`')
        elif tag == 'pre':
            self.in_pre = False
            self.result.append('\n```\n\n')
        elif tag == 'a':
            if self.current_link:
                self.result.append(f']({self.current_link})')
                self.current_link = None
            else:
                self.result.append(']')
        elif tag == 'blockquote':
            self.result.append('\n\n')
        elif tag in ('ul', 'ol'):
            if self.list_index_stack:
                self.list_index_stack.pop()
            self.result.append('\n')
        elif tag == 'li':
            pass

    def handle_data(self, data):
        if self.in_table and self.in_cell:
            self.cell_content.append(data)
        elif self.in_pre:
            self.result.append(data)
        else:
            # Clean up whitespace but preserve standard spacing
            clean_data = re.sub(r'\s+', ' ', data)
            if clean_data:
                self.result.append(clean_data)

    def render_table(self):
        if not self.table_data:
            return
        
        # Determine number of columns
        cols = max(len(row) for row in self.table_data)
        
        # Normalize all rows to have the same number of columns
        for row in self.table_data:
            while len(row) < cols:
                row.append('')
                
        table_md = []
        # Header row
        header = self.table_data[0]
        table_md.append('| ' + ' | '.join(header) + ' |')
        
        # Divider row
        table_md.append('| ' + ' | '.join(['---'] * cols) + ' |')
        
        # Data rows
        for row in self.table_data[1:]:
            table_md.append('| ' + ' | '.join(row) + ' |')
            
        self.result.append('\n\n' + '\n'.join(table_md) + '\n\n')

    def get_markdown(self):
        text = ''.join(self.result)
        # Post-process to remove excessive newlines
        text = re.sub(r'\n{3,}', '\n\n', text)
        return text.strip()

def main():
    # Read HTML content from stdin
    html_content = sys.stdin.read()
    if not html_content.strip():
        sys.exit(0)

    parser = HTMLToMarkdown()
    parser.feed(html_content)
    print(parser.get_markdown())

if __name__ == '__main__':
    main()
