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
       string[] files;
       List<string> indexes = new List<string>();
        string mountPath = "C:\\Temp\\";
       string directoryPath = "C:\\Temp\\";
       string visualStudioPath = "C:\\Program Files (x86)\\Microsoft Visual Studio 10.0\\Common7\\IDE\\devenv.exe";

        public Form1()
        {
            if(Directory.Exists(mountPath)){
                InitializeComponent();
                this.textBox1.KeyDown += new KeyEventHandler(textBox1_KeyDown);
                this.files = Directory.GetFiles(mountPath, "*.*", SearchOption.AllDirectories);
                this.label1.Text = "Current Index: " + mountPath;
                this.indexes.Add(mountPath);
                updateCombobox();
            }
            else{
                 MessageBox.Show("You must have "+mountPath+"!");
            }
        }

        
        private void textBox1_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Return)
            {
               updateList();
            }
        }


        private void listBox1_SelectedIndexChanged_1(object sender, EventArgs e)
        {
           string curItem;

           // Since it's set to open files on a single click, this try/catch makes sure you've actually
           // selected something before trying to open it.
           if (listBox1.SelectedIndex != -1)
           {
              try
              {
                 curItem = listBox1.SelectedItem.ToString();
                 Process process = new Process();
                 ProcessStartInfo startInfo = new ProcessStartInfo(visualStudioPath, "/edit " + curItem);
                 process.StartInfo = startInfo;
                 process.Start();
              }
              catch (NullReferenceException) {}

              // Reset SelectedItem and SelectedIndex
              listBox1.SelectedItem = null;
              listBox1.SelectedIndex = -1;
           }
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {
           //Update();
        }

        private void button1_Click(object sender, EventArgs e)
        {
           updateList();
        }

        

        private void Form1_Load(object sender, EventArgs e)
        {

        }


        private void updateList()
        {
           listBox1.Items.Clear();
           foreach (string f in this.files)
           {
              if (Regex.IsMatch(f, textBox1.Text, RegexOptions.IgnoreCase))
              //if(f.Contains(textBox1.Text))
              {
                 listBox1.Items.Add(f);
              }
           }
        }

        private void updateDirectory()
        {
           this.files = Directory.GetFiles(directoryPath, "*.*", SearchOption.AllDirectories);
        }

        private void button2_Click(object sender, EventArgs e)
        {
            if (folderBrowserDialog1.ShowDialog() == DialogResult.OK)
            {
                this.directoryPath = folderBrowserDialog1.SelectedPath;
                this.indexes.Add(directoryPath);
                updateCombobox();
                updateDirectory();
                UpdateLabel();
            }

        }

        private void updateCombobox()
        {
            this.comboBox1.Items.Clear();
            foreach(string path in this.indexes)
            {
                this.comboBox1.Items.Add(path);
            }
        }

        private void UpdateLabel()
        {
            this.label1.Text = "Current Index: " + this.directoryPath;
        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            string currItem;
            currItem = comboBox1.SelectedItem.ToString();
            directoryPath = currItem;
            updateDirectory();
            UpdateLabel();
            updateList();
        }
    }
}
