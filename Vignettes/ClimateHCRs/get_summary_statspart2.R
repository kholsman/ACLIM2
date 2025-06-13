# ------
# Get summary statistics relative to status quo
# proj_SSB_all




sub_biom_scen   <- proj_SSB_all%>%filter(year>2025, fishing=="fishing", gcmscen !="mn_Hind")%>%
  rename(SSB = value)%>%
  select(-proj_type)
sub_biom_mnhind <- proj_SSB_all%>%filter(year>2025, fishing=="fishing", gcmscen =="mn_Hind")%>%
  rename(SSB_mnhind = value)%>%
  select(-proj_type)

sub <- sub_biom_scen%>%
  left_join(
    sub_biom_mnhind%>%select(-gcmscen, -scen, -gcm,-fut_simulation))%>%
  mutate(delta = SSB-SSB_mnhind,
         delta_prcnt = (SSB-SSB_mnhind)/SSB_mnhind)

sum_list <- names(sub%>%select(-delta_prcnt,-SSB_mnhind,-delta,-SSB,-year))

# get total number of SSB years
sub_tot <- sub%>%group_by(across(sum_list))%>%
  summarize(total = length(SSB))%>%data.frame()

# get total number of SSB crashes
sub_0 <- sub%>%filter(SSB ==0 )%>%
  group_by(across(sum_list))%>%
  summarize(num_0 = length(SSB))%>%
  data.frame()

# get total number of years where SSB drops below a 10% decline
sub_10 <- sub%>%filter(delta_prcnt <= -.1)%>%
  group_by(across(sum_list))%>%
  summarize(num_10prcnt = length(SSB))%>%
  data.frame()

# get total number of years where SSB drops below a 50% decline
sub_50 <- sub%>%filter(delta_prcnt <= -.5)%>%
  group_by(across(sum_list))%>%
  summarize(num_50prcnt = length(SSB))%>%
  data.frame()

# get total number of years where SSB drops below a 80% decline
sub_80 <- sub%>%filter(delta_prcnt <= -.8)%>%
  group_by(across(sum_list))%>%
  summarize(num_80prcnt = length(SSB))%>%
  data.frame()

# join it all up and get summary stats:
sub_tot_new <- sub_tot%>%
  left_join(sub_0)%>%
  left_join(sub_10)%>%
  left_join(sub_50)%>%
  left_join(sub_80)%>%
  mutate(across(c("total","num_0","num_10prcnt","num_50prcnt","num_80prcnt"), as.character ))%>%
  mutate(across(c("total","num_0","num_10prcnt","num_50prcnt","num_80prcnt"), as.numeric))%>%
  mutate(across(c("total","num_0","num_10prcnt","num_50prcnt","num_80prcnt"), coalesce, 0))%>%
  mutate(across(c("num_0","num_10prcnt","num_50prcnt","num_80prcnt"), function(x)  x/total))


mn<- sub_tot_new%>%
  filter(HCRsim!="No HCR")%>%
  group_by(across(
    names(sub_tot_new%>%
            select(-fut_simulation,-gcmscen,-gcm,
                   -total, -num_0, -num_10prcnt,
                   -num_50prcnt,-num_80prcnt))
  ) )%>%
  summarize_at(all_of(c("num_0","num_10prcnt","num_50prcnt","num_80prcnt")),mean) %>%data.frame()


se <- sub_tot_new%>%
  filter(HCRsim!="No HCR")%>%
  group_by(across(
    names(sub_tot_new%>%
            select(-fut_simulation,-gcmscen,-gcm,
                   -total, -num_0, -num_10prcnt,
                   -num_50prcnt,-num_80prcnt))
  ) )%>%
  summarize_at(all_of(c("num_0","num_10prcnt","num_50prcnt","num_80prcnt")),function(x) sd(x)/sqrt(length(x))) %>%data.frame()

names(se%>%select(-num_0,-num_10prcnt,-num_50prcnt,-num_80prcnt))

biom_stats <-mn%>%left_join(se, suffix = c("_mn", "_se"),
                            by =names(se%>%select(-num_0,-num_10prcnt,-num_50prcnt,-num_80prcnt)))


get_hcr_num <- function(x){
  out <-  strsplit(x,"HCR_")[[1]][2]
  out <- substr(out,1,nchar(out)-1)
  return(out)
}

biom_stats$HCR_num <- purrr::map(biom_stats$HCR, get_hcr_num) |> unlist()

# ------
# Get summary statistics
# proj_catch_all

sub_catch_scen   <- proj_catch_all%>%filter(year>2025, fishing=="fishing", gcmscen !="mn_Hind")%>%
  rename(ABC = value)%>%
  select(-proj_type)
sub_catch_mnhind <- proj_catch_all%>%filter(year>2025, fishing=="fishing", gcmscen =="mn_Hind")%>%
  rename(ABC_mnhind = value)%>%
  select(-proj_type)

sub_catch <- sub_catch_scen%>%
  left_join(
    sub_catch_mnhind%>%select(-gcmscen, -scen, -gcm,-fut_simulation))%>%
  mutate(delta = ABC-ABC_mnhind,
         delta_prcnt = (ABC-ABC_mnhind)/ABC_mnhind)

sum_list <- names(sub_catch%>%select(-delta_prcnt,-ABC_mnhind,-delta,-ABC,-year))

# get total number of ABC years
sub_tot <- sub_catch%>%group_by(across(sum_list))%>%
  summarize(total = length(ABC))%>%data.frame()

# get total number of fishery closures
sub_0 <- sub_catch%>%filter(ABC ==0 )%>%
  group_by(across(sum_list))%>%
  summarize(num_0 = length(ABC))%>%
  data.frame()

# get total number of years where catch drops below a 10% decline
sub_10 <- sub_catch%>%filter(delta_prcnt <= -.1)%>%
  group_by(across(sum_list))%>%
  summarize(num_10prcnt = length(ABC))%>%
  data.frame()

# get total number of years where catch drops below a 50% decline
sub_50 <- sub_catch%>%filter(delta_prcnt <= -.5)%>%
  group_by(across(sum_list))%>%
  summarize(num_50prcnt = length(ABC))%>%
  data.frame()

# get total number of years where catch drops below a 80% decline
sub_80 <- sub_catch%>%filter(delta_prcnt <= -.8)%>%
  group_by(across(sum_list))%>%
  summarize(num_80prcnt = length(ABC))%>%
  data.frame()

# join it all up and get summary stats:
sub_tot_new <- sub_tot%>%
  left_join(sub_0)%>%
  left_join(sub_10)%>%
  left_join(sub_50)%>%
  left_join(sub_80)%>%
  mutate(across(c("total","num_0","num_10prcnt","num_50prcnt","num_80prcnt"), as.character ))%>%
  mutate(across(c("total","num_0","num_10prcnt","num_50prcnt","num_80prcnt"), as.numeric))%>%
  mutate(across(c("total","num_0","num_10prcnt","num_50prcnt","num_80prcnt"), coalesce, 0))%>%
  mutate(across(c("num_0","num_10prcnt","num_50prcnt","num_80prcnt"), function(x)  x/total))


mn<- sub_tot_new%>%
  filter(HCRsim!="No HCR")%>%
  group_by(across(
    names(sub_tot_new%>%
            select(-fut_simulation,-gcmscen,-gcm,
                   -total, -num_0, -num_10prcnt,
                   -num_50prcnt,-num_80prcnt))
  ) )%>%
  summarize_at(all_of(c("num_0","num_10prcnt","num_50prcnt","num_80prcnt")),mean) %>%data.frame()


se <- sub_tot_new%>%
  filter(HCRsim!="No HCR")%>%
  group_by(across(
    names(sub_tot_new%>%
            select(-fut_simulation,-gcmscen,-gcm,
                   -total, -num_0, -num_10prcnt,
                   -num_50prcnt,-num_80prcnt))
  ) )%>%
  summarize_at(all_of(c("num_0","num_10prcnt","num_50prcnt","num_80prcnt")),function(x) sd(x)/sqrt(length(x))) %>%data.frame()

names(se%>%select(-num_0,-num_10prcnt,-num_50prcnt,-num_80prcnt))

catch_stats <-mn%>%left_join(se, suffix = c("_mn", "_se"),
                             by = names(se%>%select(-num_0,-num_10prcnt,-num_50prcnt,-num_80prcnt)))


catch_stats$HCR_num <- purrr::map(catch_stats$HCR, get_hcr_num) |> unlist()


catch_stats2 <- catch_stats%>%
  mutate(HCR_num = factor(HCR_num,levels = 1:10),
                                    HCR     = factor(HCR, levels = HCRset_sub))
biom_stats2  <- biom_stats%>%mutate(HCR_num = factor(HCR_num,levels = 1:10),
                                   HCR     = factor(HCR, levels = HCRset_sub))

ggplot()+
  geom_col(data=catch_stats2,aes(x=HCR, y=num_50prcnt_mn,fill = factor(HCR_num,levels = 1:10)))+
  facet_grid(.~species)+
  scale_fill_viridis(discrete = T, option = "mako",begin = 0.2, end = .8)+
  theme_minimal()



