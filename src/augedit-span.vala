/* Copyright 2012 Francis Giraldeau
 *
 * This software is licensed under the GNU General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

using Augeas;

public class AugSpan : Object {

    public uint label_start { get; set; default = 0; }
    public uint label_end   { get; set; default = 0; }
    public uint value_start { get; set; default = 0; }
    public uint value_end   { get; set; default = 0; }
    public uint span_start  { get; set; default = 0; }
    public uint span_end    { get; set; default = 0; }
    private string _filename = "";
    public string filename  {
        get { return _filename; }
        set { _filename = (value == null ? "" : value); }
    }

    public void fetch(Augeas.Tree aug, string path) {
        string s;
        uint[] idx = new uint[6];
        int ret = aug.span(path, out s,
            out idx[0], out idx[1],
            out idx[2], out idx[3],
            out idx[4], out idx[5]);
        if (ret != 0)
            return;
        filename = s;
        label_start = idx[0];
        label_end = idx[1];
        value_start = idx[2];
        value_end = idx[3];
        span_start = idx[4];
        span_end = idx[5];
    }

    public string to_string() {
        string s = @"[$filename" +
                   @"($label_start:$label_end)" +
                   @"($value_start:$value_end)" +
                   @"($span_start:$span_end)]";
        return s;
    }

}
