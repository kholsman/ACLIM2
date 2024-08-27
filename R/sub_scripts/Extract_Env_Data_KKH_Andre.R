


# Extract Env Data v KKH
# rm(list=ls())
library(dplyr)
outfldr <- "Data/out/RKC_indices"

load(file.path(outfldr,"hind_RKC_immature_males_monthly_avg.Rdata"))
load(file.path(outfldr,"fut_RKC_immature_males_monthly_avg.Rdata"))

mo_nm <- c("YEAR","JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC")

sims  <- unique(fut_RKC_immature_males_monthly_avg$sim)
vars <- unique(hind_RKC_immature_males_monthly_avg$var)


if(!dir.exists(file.path(outfldr,"wide"))) dir.create(file.path(outfldr,"wide"))

for(i in 1:length(vars)){
  hind <- hind_RKC_immature_males_monthly_avg%>%filter(var==vars[i])%>%mutate(mo = mo_nm[mo])%>%
  pivot_wider(id_cols = c(year), values_from = val_use,names_from = mo )
  save(hind, file = file.path(outfldr,paste0("wide/hind_",vars[i],"_monthly_avg.Rdata")))
  write.csv(hind, file = file.path(outfldr,paste0("wide/hind_",vars[i],"_monthly_avg.csv")))
}


for(s in 1:length(sims)){
  for(i in 1:length(vars)){
    fut <- fut_RKC_immature_males_monthly_avg%>%filter(sim==sims[s],var==vars[i])%>%mutate(mo=as.numeric(mo),mo = mo_nm[mo])%>%
      pivot_wider(id_cols = c(year), values_from = val_use,names_from = mo )
    
    save(fut, file = file.path(outfldr,paste0("wide/fut_",vars[i],"_",sims[s],"_monthly_avg.Rdata")))
    write.csv(fut, file = file.path(outfldr,paste0("wide/fut_",vars[i],"_",sims[s],"_monthly_avg.csv")))
    
  }
}
