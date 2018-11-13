--------------------------------------------------------------------------------
--! 5307474 Bruno de Carvalho Albertini
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

-- @brief Raiz Quadrada
entity square is
  port (
    X     : in  signed(7 downto 0); -- entrada
    S     : out signed(7 downto 0); -- saida
    reset : in  bit; -- reset ativo alto assíncrono
    done  : out bit; -- alto quando terminou de calcular
    clk   : in  bit
  );
end entity square;

architecture comp of square is
  component square_fd is
    port (
      A     : in  signed(7 downto 0);
      square        : out signed(7 downto 0);
      QA : out signed (7 downto 0);
      resposta : out signed (7 downto 0);
      done : in  bit;
      reset : in  bit;
      itera   : in  bit
    );
  end component;
  component square_uc is
    port (
      itera : out bit;
      reset : out bit;
      square   : in  signed (7 downto 0);
      A : in  signed (7 downto 0);
      clk   : in  bit
    );
  end component;
  signal QA, itera, square : bit;
begin
  fd: square_fd port map(X, square, QA, S, done, reset, itera);
  uc: square_uc port map(itera, reset, square, QA, clk);
end architecture;


entity square_fd is
  port (

  );
end entity square_fd;

architecture fd of square_fd is

begin

end architecture;

entity square_uc is
  port (

  );
end entity square_uc;

architecture uc of square_uc is

begin

end architecture;
