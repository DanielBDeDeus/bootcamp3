# Análise comparativa e avaliação crítica do uso de IA

## Método

Toda ferramenta avaliada deve receber o mesmo problema e os mesmos critérios. Não registrar uma ferramenta como utilizada se ela não tiver sido realmente testada.

## Matriz de avaliação

| Ferramenta | Tarefa executada | Resultado observado | Limitação observada | Impacto nos testes | Homologação humana |
|---|---|---|---|---|---|
| Ferramenta 1 | Executar o roteiro padrão | A executar | A executar | A executar | Obrigatória |
| Ferramenta 2 | Executar o roteiro padrão | A executar | A executar | A executar | Obrigatória |
| Ferramenta 3 | Executar o roteiro padrão | A executar | A executar | A executar | Obrigatória |

## Ética, limites e segurança

### Riscos de alucinação de código e geração de código inseguro

Um agente pode sugerir APIs inexistentes, validações incompletas ou código plausível que falha em cenários de borda. A saída do agente não é critério de aceite. A equipe utiliza testes automatizados, revisão de código e validação funcional.

### Vazamento de dados, privacidade e confidencialidade

Tokens, senhas, chaves privadas, dados pessoais e informações institucionais restritas não devem ser enviados aos agentes. O projeto usa apenas dados fictícios.

### Propriedade intelectual

Saídas de ferramentas de IA avaliadas pela equipe devem ser analisadas quanto à origem, licenciamento e compatibilidade. Nenhuma saída deve ser aceita automaticamente sem verificação.

### Centralidade da homologação e revisão humana

A responsabilidade pelas decisões técnicas continua sendo da equipe. Nenhum merge deve ocorrer apenas porque um agente afirmou que a solução está correta.