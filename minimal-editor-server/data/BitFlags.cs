using System;
using System.Collections.Generic;
using System.Text;

public class BitFlags
{
    private int _flags;
    private readonly int _flagLength;

    /// <summary>
    /// Initializes the BitFlags class with a specific capacity.
    /// </summary>
    /// <param name="flagLength">The total number of boolean flags available.</param>
    public BitFlags(int flagLength)
    {
        if (flagLength <= 0 || flagLength > 32)
        {
            // Since we are using 'int' as storage, max 32 bits.
            throw new ArgumentException("FlagLength must be between 1 and 32.", nameof(flagLength));
        }

        _flagLength = flagLength;
        _flags = 0;
    }

    public void SetFlag(int index, bool state)
    {
        ValidateIndex(index);

        if (state)
        {
            _flags |= (1 << index);
        }
        else
        {
            _flags &= ~(1 << index);
        }
    }

    public bool GetFlag(int index)
    {
        ValidateIndex(index);
        return (_flags & (1 << index)) != 0;
    }

    public void ImportFromList(List<bool> boolList)
    {
        _flags = 0;
        
        // Determine how many items we actually need to copy
        int count = Math.Min(boolList.Count, _flagLength);

        for (int i = 0; i < count; i++)
        {
            if (boolList[i])
            {
                _flags |= (1 << i);
            }
        }
    }

    public List<bool> ExportToList()
    {
        List<bool> list = new List<bool>(_flagLength);
        
        for (int i = 0; i < _flagLength; i++)
        {
            list.Add(GetFlag(i));
        }
        
        return list;
    }

    public int GetValue()
    {
        return _flags;
    }

    public string GetHexValue()
    {
        return "0x" + _flags.ToString("X");
    }

    public string GetBinaryString()
    {
        var sb = new StringBuilder();

        // Loop only up to the defined FlagLength, not 32
        for (int i = 0; i < _flagLength; i++)
        {
            // Append 1 if flag is set, 0 otherwise
            sb.Append((_flags & (1 << i)) != 0 ? "1" : "0");
        }

        return sb.ToString();
    }

    private void ValidateIndex(int index)
    {
        if (index < 0 || index >= _flagLength)
        {
            throw new ArgumentOutOfRangeException(nameof(index), $"Index must be between 0 and {_flagLength - 1}.");
        }
    }
}
