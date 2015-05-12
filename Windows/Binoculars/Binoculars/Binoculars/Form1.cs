using System;
using System.IO;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Diagnostics;
using System.Text.RegularExpressions;

namespace Binoculars
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
            this.textBox1.KeyDown += new KeyEventHandler(textBox1_KeyDown);
            this.files = Directory.GetFiles(@"C:\Users\phoncey\Documents\amber");
            Console.WriteLine("--- Files: ---");
            foreach (string name in this.files)
            {
                Console.WriteLine(name);
            }
        }

        string[] files;
        private void textBox1_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Return)
            {
                listBox1.Items.Clear();
                foreach (string f in this.files) 
                {
                    //if(Regex.IsMatch(f, textBox1.Text, RegexOptions.IgnoreCase))
                    if(f.Contains(textBox1.Text))
                    {
                        listBox1.Items.Add(f);
                    }
                }
            }
        }


        private void listBox1_SelectedIndexChanged_1(object sender, EventArgs e)
        {
            string curItem = listBox1.SelectedItem.ToString();
            Process process = new Process();
            ProcessStartInfo startInfo = new ProcessStartInfo("C:\\Program Files (x86)\\Microsoft Visual Studio 10.0\\Common7\\IDE\\devenv.exe", "/edit " + curItem);
            process.StartInfo = startInfo;
            process.Start();
            //MessageBox.Show("Item selected is " + curItem);
        }
    }
}
