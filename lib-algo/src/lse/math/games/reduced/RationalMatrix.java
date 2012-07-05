package lse.math.games.reduced;

import java.io.StringWriter;
import java.util.logging.Logger;

import lse.math.games.Rational;
import lse.math.games.io.ColumnTextWriter;

public class RationalMatrix 
{
	private static final Logger log = Logger.getLogger(RationalMatrix.class.getName());
	
	private Rational[][] _matrix;
	private int _row;
	private int _column;
	
	public RationalMatrix(int m, int n) {
		this(m,n,false);
	}
	
	public RationalMatrix(int m, int n, boolean unit) {
		_row = m;
		_column = n;
		_matrix = new Rational[_row][_column];
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				if (unit == true && i == j) {
					_matrix[i][j] = Rational.ONE;
				} else {
					_matrix[i][j] = Rational.ZERO;
				}
			}
		}
	}
	
	public RationalMatrix(RationalMatrix other) {
		_row = other._row;
		_column = other._column;
		
		_matrix = new Rational[_row][_column];
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				_matrix[i][j] = new Rational(other._matrix[i][j]);
			}
		}
	}

	public RationalMatrix(Integer[][] other) {
		_row = other.length;
		if (_row == 0) {
			return;
		}
		
		_column = other[0].length;
		
		_matrix = new Rational[_row][_column];
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				_matrix[i][j] = Rational.valueOf(other[i][j]);
			}
		}
	}
	
	public RationalMatrix(Rational[][] other) {
		_row = other.length;
		if (_row == 0) {
			return;
		}
		
		_column = other[0].length;
		
		_matrix = new Rational[_row][_column];
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				_matrix[i][j] = new Rational(other[i][j]);
			}
		}
	}
	
	public RationalMatrix copy() {
		RationalMatrix result = new RationalMatrix(_row, _column);
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				result._matrix[i][j] = new Rational(_matrix[i][j]);
			}
		}
		return result;
	}
	
	public RationalMatrix appendBelow(RationalMatrix other) {
		if (_column != other._column) {
			return null;
		}
		
		RationalMatrix result = new RationalMatrix(_row + other._row, _column);
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				result._matrix[i][j] = new Rational(_matrix[i][j]);
			}
		}
		for (int i = 0; i < other._row; i++) {
			for (int j = 0; j < other._column; j++) {
				result._matrix[_row + i][j] = new Rational(other._matrix[i][j]);
			}
		}
		return result;
	}
	
	public RationalMatrix appendAfter(RationalMatrix other) {
		if (_row != other._row) {
			return null;
		}
		
		RationalMatrix result = new RationalMatrix(_row, _column + other._column);
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				result._matrix[i][j] = new Rational(_matrix[i][j]);
			}
			for (int j = 0; j < other._column; j++) {
				result._matrix[i][_column + j] = new Rational(other._matrix[i][j]);
			}
		}
		return result;
	}
	
	public RationalMatrix multiply(Rational alpha) {
		
		RationalMatrix result = new RationalMatrix(_row, _column);
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				result._matrix[i][j] = _matrix[i][j].multiply(alpha);
			}
		}		
		return result;
	}
	
	public RationalMatrix multiply(RationalMatrix other) {

		if (_column != other._row) {
			return null;
		}
		
		RationalMatrix result = new RationalMatrix(_row, other._column);
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < other._column; j++) {
				
				result._matrix[i][j] = Rational.ZERO;
				
				for (int k = 0; k < _column; k++) {
					result._matrix[i][j] = result._matrix[i][j].add(_matrix[i][k].multiply(other._matrix[k][j]));
				}
			}
		}		
		return result;
	}

	public RationalMatrix add(RationalMatrix other) {
		if (_row != other._row || _column != other._column) {
			return null;
		}
		
		RationalMatrix result = new RationalMatrix(_row, _column);
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				result._matrix[i][j] = _matrix[i][j].add(other._matrix[i][j]);
			}
		}		
		return result;
	}

	public RationalMatrix transpose() {
		RationalMatrix result = new RationalMatrix(_column, _row);
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				result._matrix[j][i] = new Rational(_matrix[i][j]);
			}
		}
		return result;
	}

	public void setElement(int i, int j, Rational r) {
		_matrix[i][j] = new Rational(r);
	}
	
	public Rational getElement(int i, int j) {
		return _matrix[i][j];
	}

	public RationalMatrix getSubmatrix(int i0, int j0, int i1, int j1) {
		RationalMatrix result = new RationalMatrix(i1-i0, j1-j0);
		for (int i = 0; i < i1-i0; i++) {
			for (int j = 0; j < j1-j0; j++) {
				result._matrix[i][j] = new Rational(_matrix[i0+i][j0+j]);
			}
		}
		return result;
	}
	
	
	public int getRowSize() {
		return _row;
	}

	public int getColumnSize() {
		return _column;
	}
	
	public RationalMatrix inverse() {
		RationalMatrix result = this.copy();
		result.invert();
		return result;
	}
	
	public void invert() {
		if (_row != _column) {
			return;
		}
		
		RationalMatrix temp = new RationalMatrix(_row, _row * 2);
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				temp._matrix[i][j] = new Rational(_matrix[i][j]);
			}
			for (int j = 0; j < _column; j++) {
				if (i == j) {
					temp._matrix[i][_column + j] = Rational.ONE;
				} else {
					temp._matrix[i][_column + j] = Rational.ZERO;
				}
			}
		}
		
		temp.gaussJordanElimination();
		
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				_matrix[i][j] = temp._matrix[i][_column + j];
			}
		}
	}
	
	void gaussJordanElimination() {
		
		int size = 0;
		for (int k = 0; k < _column && size < _row; k++ ) {
			if (_matrix[k][k].isZero()) {
				continue;
			}
			
			size++;
			
			for (int i = 0; i < _row; i++) {
				if (i != k) {
					Rational sum = _matrix[i][k].divide(_matrix[k][k]);
					for (int j = k; j < _column; j++) {
						_matrix[i][j] = _matrix[i][j].subtract(sum.multiply(_matrix[k][j]));
					}
				}
			}
		}
		
		for (int k = 0; k < _row; k++ ) {
			for (int j = _row; j < _column; j++ ) {
				_matrix[k][j] = _matrix[k][j].divide(_matrix[k][k]); 
			}
			_matrix[k][k] = Rational.ONE;
		}
	}

	@Override
	public 	String toString() {
		ColumnTextWriter colpp = new ColumnTextWriter();
		
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				colpp.writeCol(_matrix[i][j].toString());
			}
			/* Make new line */
			colpp.endRow();
		}
		
		StringWriter output = new StringWriter();
		output.write(colpp.toString());
		return output.toString();
	}
	
	/*// utils //*/
	private void logi(String format, Object... args) {
		log.info(String.format(format, args));
	}
	
	private void logi(ColumnTextWriter colpp) {
		StringWriter output = new StringWriter();
		output.write(colpp.toString());
		
		log.info(String.format(output.toString()));
	}
}
