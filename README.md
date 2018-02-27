# Installera git:

I kommandoprompten, skriv 'git version'. Om du har git installerat får du ett svar i stil med:
'git version 2.15.1'
Om inte så klagar datorn på att den inte förstår vad du försöker säga. Följ isåfall denna genomgången:
https://www.atlassian.com/git/tutorials/install-git
Ställ in ditt namn och email enligt sista biten i windows genomgången. Nu har du git på din dator.

# Ladda ner projektet:

I kommandoprompten, navigera till där du vill ha projektet. Jag skulle rekomendera att ha det någonstans i din MATLAB-path, men du väljer själv. När du väl är där, skriver du in 'git clone ...' där '...'' är det som står med på start sidan i Atlassian. Allting laddas förhoppningsvis ner och vouila, du har senaste versionen.

# Hur gör man?

Läs på här, dem har en bra genomgång:
https://git-scm.com/book/en/v2
Kolla speciellt kapitel 2. Git Basics och 3. Git Branching. Om du vill ha lite mer bakgrund kan du ögna igenom kapitel 1. Getting Started. Dem förklarar hur man gör det mesta via kommandoprompten. Man behöver inte läsa igenom supernoga, men  Om du vill köra via ngt annat verktyg än kommandoprompten är du varmt välkommen, men jag vet inte hur man gör. 
Kom ihåg att:

- Pulla ner senaste versionen innan du skapar en ny branch. 

- Commita dina filer när du känner dig nöjd.

- Pusha din commit när du är helnöjd.

- Mergea in din branch i master ENDAST om du vet att den fungerar. 

- Inte jobba direkt i master branchen. 

# Workflow för en feature

Brancha: 
- $ git checkout -b name 

	kort för:	

	$ git branch name 

	$ git checkout name

- Jobba på, koda tills du blir blå. När du är färdig med en bit av det hela:

		Lägg till dina filer:

		$ git add filnamn.txt filmjölk.fil ...

		Commita med ett kort medelande:
		
		$ git commit –m ’lorem ipsum’

- Pulla: $ git pull

- Pusha: $ git push

- Jobba på och comitta mer och mer tills du är färdig med hela featuren.
- Mergea hela featuren:
	
	Checka ut mastern:

	$ git checkout master 

	Switched to branch 'master’

	$ git merge name

	Merge made by the 'recursive' strategy. 

	index.html | 1 + 
	
	1 file changed, 1 insertion(+)
