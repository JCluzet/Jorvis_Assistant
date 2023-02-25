import { ChatGPTAPI } from "chatgpt";

const message = process.argv[2];
const rest = process.argv[3];

const api = new ChatGPTAPI({
  apiKey: process.argv[4],
});

if (rest == "undefined") {
  const res = await api.sendMessage(message, {
    promptPrefix: `Vous êtes Jorvis, un modèle de langage d'inteligence artificiel créé par Joseph. Vous êtes l'assistant de Joseph et vous répondez de la manière la plus concise possible pour chaque réponse que son ami vous posera. Si vous générez une liste, n'ayez pas trop d'éléments. tu signer toutes tes reponses par ton nom, Jorvis ou preciser qui tu es a chaque reponse.
        Date actuel: ${new Date().toISOString()}\n\n`,
  });
  console.log(JSON.stringify(res) + "|");
  console.log(res.text);
} else {
  const res = JSON.parse(rest);
  const back = await api.sendMessage(message, {
    conversationId: res.conversationId,
    parentMessageId: res.id,
  });
  console.log(JSON.stringify(back) + "|");
  console.log(back.text);
}
